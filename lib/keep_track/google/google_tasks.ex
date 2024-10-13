defmodule KeepTrack.Google.GoogleServices do
  alias GoogleApi.Tasks.V1.Connection, as: TasksConnection
  alias GoogleApi.Tasks.V1.Api.Tasklists

  def list_task_lists(access_token) do
    connection = TasksConnection.new(access_token)
    {:ok, %{items: task_lists}} = Tasklists.tasks_tasklists_list(connection)
    task_lists
  end
end
