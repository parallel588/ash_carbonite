defmodule AshCarbonite.Mix.Helpers do
  @moduledoc false
  def domains!(opts, args) do
    apps =
      if apps_paths = Mix.Project.apps_paths() do
        apps_paths |> Map.keys() |> Enum.sort()
      else
        [Mix.Project.config()[:app]]
      end

    configure_domains = Enum.flat_map(apps, &Application.get_env(&1, :ash_domains, []))

    domains =
      if opts[:domains] && opts[:domains] != "" do
        opts[:domains]
        |> Kernel.||("")
        |> String.split(",")
        |> Enum.flat_map(fn
          "" ->
            []

          domain ->
            [Module.concat([domain])]
        end)
      else
        configure_domains
      end

    domains
    |> Enum.map(&ensure_compiled(&1, args))
    |> case do
      [] ->
        []

      domains ->
        domains
    end
  end

  defp ensure_compiled(domain, args) do
    ensure_load(args)

    case Code.ensure_compiled(domain) do
      {:module, _} ->
        domain
        |> Ash.Domain.Info.resources()
        |> Enum.each(&Code.ensure_compiled/1)

        # TODO: We shouldn't need to make sure that the resources are compiled

        domain

      {:error, error} ->
        Mix.raise("Could not load #{inspect(domain)}, error: #{inspect(error)}. ")
    end
  end

  defp ensure_load(args) do
    if Code.ensure_loaded?(Mix.Tasks.App.Config) do
      Mix.Task.run("app.config", args)
    else
      Mix.Task.run("loadpaths", args)
      "--no-compile" not in args && Mix.Task.run("compile", args)
    end
  end
end
