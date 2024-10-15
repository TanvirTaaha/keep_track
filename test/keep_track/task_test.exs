defmodule KeepTrack.TaskTest do
  use KeepTrack.DataCase

  alias KeepTrack.Task

  describe "tasklists" do
    alias KeepTrack.Task.TaskList

    import KeepTrack.TaskFixtures

    @invalid_attrs %{title: nil, kind: nil, etag: nil, listid: nil, selfLink: nil, updated: nil}

    test "list_tasklists/0 returns all tasklists" do
      task_list = task_list_fixture()
      assert Task.list_tasklists() == [task_list]
    end

    test "get_task_list!/1 returns the task_list with given id" do
      task_list = task_list_fixture()
      assert Task.get_task_list!(task_list.id) == task_list
    end

    test "create_task_list/1 with valid data creates a task_list" do
      valid_attrs = %{title: "some title", kind: "some kind", etag: "some etag", listid: "some listid", selfLink: "some selfLink", updated: "some updated"}

      assert {:ok, %TaskList{} = task_list} = Task.create_task_list(valid_attrs)
      assert task_list.title == "some title"
      assert task_list.kind == "some kind"
      assert task_list.etag == "some etag"
      assert task_list.listid == "some listid"
      assert task_list.selfLink == "some selfLink"
      assert task_list.updated == "some updated"
    end

    test "create_task_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Task.create_task_list(@invalid_attrs)
    end

    test "update_task_list/2 with valid data updates the task_list" do
      task_list = task_list_fixture()
      update_attrs = %{title: "some updated title", kind: "some updated kind", etag: "some updated etag", listid: "some updated listid", selfLink: "some updated selfLink", updated: "some updated updated"}

      assert {:ok, %TaskList{} = task_list} = Task.update_task_list(task_list, update_attrs)
      assert task_list.title == "some updated title"
      assert task_list.kind == "some updated kind"
      assert task_list.etag == "some updated etag"
      assert task_list.listid == "some updated listid"
      assert task_list.selfLink == "some updated selfLink"
      assert task_list.updated == "some updated updated"
    end

    test "update_task_list/2 with invalid data returns error changeset" do
      task_list = task_list_fixture()
      assert {:error, %Ecto.Changeset{}} = Task.update_task_list(task_list, @invalid_attrs)
      assert task_list == Task.get_task_list!(task_list.id)
    end

    test "delete_task_list/1 deletes the task_list" do
      task_list = task_list_fixture()
      assert {:ok, %TaskList{}} = Task.delete_task_list(task_list)
      assert_raise Ecto.NoResultsError, fn -> Task.get_task_list!(task_list.id) end
    end

    test "change_task_list/1 returns a task_list changeset" do
      task_list = task_list_fixture()
      assert %Ecto.Changeset{} = Task.change_task_list(task_list)
    end
  end
end
