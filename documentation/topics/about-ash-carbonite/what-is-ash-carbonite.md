# What is AshCarbonite?

AshCarbonite is an integration between [Ash](https://ash-hq.org) and [Carbonite](https://github.com/ash-project/carbonite) that provides versioning capabilities for your Ash resources.

Use this to keep a history of changes to your records. For example, the resource below would be versioned in a table called `posts_versions`:

```elixir
defmodule MyApp.Post do
  use Ash.Resource,
    extensions: [AshCarbonite.Resource]

  attributes do
    uuid_primary_key :id
    attribute :title, :string
    attribute :content, :string
  end

  carbonite do
    primary_key_columns ["id"]
  end
end
```

When a `MyApp.Post` record is created, a corresponding record will be created in the `posts_versions` table. When the post is updated, a new version will be created in the `posts_versions` table.
