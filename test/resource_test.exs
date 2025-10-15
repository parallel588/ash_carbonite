defmodule AshCarbonite.ResourceTest do
  use AshCarbonite.RepoCase, async: false

  alias AshCarbonite.Test.Post
  alias AshCarbonite.TestRepo

  test "creating" do
    assert {:ok, %Post{}} =
             Post
             |> Ash.Changeset.for_create(:create, %{title: "foo", content: "bar"})
             |> Ash.create()

    assert [%Post{title: "foo"}] = Ash.read!(Post)

    assert [transaction] =
             Carbonite.Query.transactions()
             |> TestRepo.all()
             |> TestRepo.preload([:changes])

    assert transaction.meta == %{"action" => "create", "resource" => "AshCarbonite.Test.Post"}
    assert [change] = transaction.changes
    assert change.op == :insert
    assert change.table_name == "posts"
    assert %{"content" => "bar", "title" => "foo"} = change.data
  end

  test "update" do
    {:ok, post} =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "foo", content: "bar"})
      |> Ash.create()

    %Post{} = Ash.update!(post, %{title: "Updated Title"})

    assert [transaction] =
             Carbonite.Query.transactions()
             |> TestRepo.all()
             |> TestRepo.preload([:changes])

    assert [change_insert, change_update] = transaction.changes
    assert change_insert.op == :insert
    assert change_insert.table_name == "posts"

    assert change_update.op == :update
    assert change_update.changed == ["title"]
    assert change_update.table_name == "posts"
  end
end
