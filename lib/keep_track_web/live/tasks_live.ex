defmodule KeepTrackWeb.Live.TasksLive do
  use KeepTrackWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Tasks"
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="tasks">
      <h1>Live h1</h1>
    </div>
    """
  end
end
