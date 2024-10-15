defmodule KeepTrack.Google.Tasks do
  alias GoogleApi.Tasks.V1.Connection, as: TasksConnection
  alias GoogleApi.Tasks.V1.Api.Tasklists
  alias GoogleApi.Tasks.V1.Api.Tasks
  alias KeepTrack.Google.GoogleAuth
  alias KeepTrackWeb.GoogleAuthController

  def list_task_lists(user) do
    connection = TasksConnection.new(GoogleAuthController.access_token_for!(user))

    case Tasklists.tasks_tasklists_list(connection) do
      {:ok, %{items: task_lists}} ->
        task_lists

      {:error, response} ->
        %{"error" => %{"message" => message, "status" => status}} = Jason.decode!(response.body)
        dbg(message)
        dbg(status)
        GoogleAuth.refresh_token(user.refresh_token)
        []
    end
  end

  def list_tasks(user, task_list) do
    connection = TasksConnection.new(user.access_token)

    case Tasks.tasks_tasks_list(connection, task_list) do
      {:ok, %{items: tasks}} ->
        tasks

      {:error, response} ->
        %{"error" => %{"message" => _message, "status" => _status}} = Jason.decode!(response.body)
        []
    end
  end
end
