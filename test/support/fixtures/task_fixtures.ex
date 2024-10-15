defmodule KeepTrack.TaskFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KeepTrack.Task` context.
  """

  @doc """
  Generate a task_list.
  """
  def task_list_fixture(attrs \\ %{}) do
    {:ok, task_list} =
      attrs
      |> Enum.into(%{
        etag: "some etag",
        kind: "some kind",
        listid: "some listid",
        selfLink: "some selfLink",
        title: "some title",
        updated: "some updated"
      })
      |> KeepTrack.Task.create_task_list()

    task_list
  end
end
