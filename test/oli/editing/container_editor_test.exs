defmodule Oli.Authoring.Editing.ContainerEditorTest do
  use Oli.DataCase

  alias Oli.Authoring.Editing.ContainerEditor
  alias Oli.Publishing.AuthoringResolver
  alias Oli.Authoring.Locks

  describe "container editing" do

    setup do
      Seeder.base_project_with_resource2()
    end

    test "list_all_pages/1 returns the pages", %{project: project, revision2: revision2, revision1: revision1 } do

      pages = ContainerEditor.list_all_pages(project)

      assert length(pages) == 2
      assert hd(pages).id == revision1.id
      assert hd(tl(pages)).id == revision2.id

    end

    test "add_new/3 creates a new page and attaches it to the root", %{author: author, project: project } do

      page = %{
        objectives: %{ "attached" => []},
        children: [],
        content: %{ "model" => []},
        title: "New Page",
        graded: true,
        resource_type_id: Oli.Resources.ResourceType.get_id_by_type("page")
      }

      {:ok, revision} = ContainerEditor.add_new(page, author, project)

      assert revision.title == "New Page"

      container = AuthoringResolver.root_resource(project.slug)

      # Ensure that the edit has inserted the new page reference
      # first in the collection
      assert length(container.children) == 3
      assert Enum.find_index(container.children, fn c -> revision.resource_id == c end) == 2

    end

    test "remove_child/3 removes correctly", %{author: author, project: project, revision1: revision1 } do

      {:ok, _} = ContainerEditor.remove_child(project, author, revision1.slug)

      # Verify we have removed it from the container
      container = AuthoringResolver.root_resource(project.slug)
      assert length(container.children) == 1
      assert Enum.find_index(container.children, fn c -> revision1.resource_id == c end) == nil

      # Verify that we have marked the resource as being deleted
      updated = AuthoringResolver.from_resource_id(project.slug, revision1.resource_id)
      assert updated.deleted == true

    end

    test "remove_child/3 fails when target resource is locked", %{publication: publication, author2: author2, author: author, project: project, page1: page1, revision1: revision1 } do

      {:acquired} = Locks.acquire(publication.id, page1.id, author2.id)

      # Verify that the remove failed due to the lock
      case ContainerEditor.remove_child(project, author, revision1.slug) do
        {:ok, _} -> assert false
        {:error, {:lock_not_acquired, _}} -> assert true
      end

    end

    test "remove_child/3 succeeds when target resource is locked by same user", %{publication: publication, author: author, project: project, page1: page1, revision1: revision1 } do

      {:acquired} = Locks.acquire(publication.id, page1.id, author.id)

      case ContainerEditor.remove_child(project, author, revision1.slug) do
        {:ok, _} -> assert true
        {:error, {:lock_not_acquired, _}} -> assert false
      end

    end

    test "reorder_child/3 reorders correctly", %{author: author, project: project } do

      page = %{
        objectives: %{ "attached" => []},
        children: [],
        content: %{ "model" => []},
        title: "New Page",
        graded: true,
        resource_type_id: Oli.Resources.ResourceType.get_id_by_type("page")
      }

      {:ok, revision} = ContainerEditor.add_new(page, author, project)

      # we now have three pages to reorder with:

      {:ok, _} = ContainerEditor.reorder_child(project, author, revision.slug, 2)
      container = AuthoringResolver.root_resource(project.slug)
      assert length(container.children) == 3
      assert Enum.find_index(container.children, fn c -> revision.resource_id == c end) == 2

      {:ok, _} = ContainerEditor.reorder_child(project, author, revision.slug, 3)
      container = AuthoringResolver.root_resource(project.slug)
      assert length(container.children) == 3
      assert Enum.find_index(container.children, fn c -> revision.resource_id == c end) == 2

      {:ok, _} = ContainerEditor.reorder_child(project, author, revision.slug, 100)
      container = AuthoringResolver.root_resource(project.slug)
      assert length(container.children) == 3
      assert Enum.find_index(container.children, fn c -> revision.resource_id == c end) == 2

      {:ok, _} = ContainerEditor.reorder_child(project, author, revision.slug, 0)
      container = AuthoringResolver.root_resource(project.slug)
      assert length(container.children) == 3
      assert Enum.find_index(container.children, fn c -> revision.resource_id == c end) == 0


    end

  end

end