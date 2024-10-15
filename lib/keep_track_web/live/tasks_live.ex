defmodule KeepTrackWeb.Live.TasksLive do
  alias KeepTrack.Accounts
  use KeepTrackWeb, :live_view

  alias KeepTrack.Google.Tasks

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Tasks",
        task_lists: [],
        tasks: [],
        selected_task_list: nil
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => gid}, _uri, socket) do
    send(self(), {:fetch_takslist, gid})
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info({:fetch_takslist, gid}, socket) do
    socket =
      case Accounts.get_user_by_google_id(gid) do
        nil ->
          socket
          |> put_flash(:error, "No user found")
          |> push_navigate(to: ~p"/")

        user ->
          task_lists = Tasks.list_task_lists(user)
          IO.puts("task_lists:#{inspect(task_lists)}")

          socket
          |> assign(task_lists: task_lists)
      end

    IO.puts("Found task_lists:")
    IO.puts(inspect(socket.assigns.task_lists))
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="tasks">
      <div class="button-container">
        <button id="my-button" phx-click="button_clicked">Click Me</button>
      </div>
      <div class="table_title">Task Lists</div>
      <div id="tasks_list_table">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>ID</th>
              <%!-- <th>Google ID</th> --%>
              <%!-- <th>Expire At</th> --%>
            </tr>
          </thead>
          <tbody>
            <%= for task_list <- @task_lists do %>
              <tr
                phx-click="task_list_clicked"
                phx-value-tlid={task_list.id}
                class={if task_list.id == @selected_task_list, do: "selected", else: ""}
              >
                <td><%= task_list.title %></td>
                <td><%= task_list.id %></td>
                <%!-- <td><%= user.google_id %></td> --%>
                <%!-- <td>
                  <%= user.token_expires_at
                  |> Timex.to_datetime("Asia/Dhaka")
                  |> Calendar.strftime("%Y/%m/%d %I:%M:%S") %>
                </td> --%>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
      <%= if not Enum.empty?(@tasks) do %>
        <div class="table_title">Tasks</div>
        <div id="tasks_table">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>ID</th>
                <%!-- <th>Google ID</th> --%>
                <%!-- <th>Expire At</th> --%>
              </tr>
            </thead>
            <tbody>
              <%= for task <- @tasks do %>
                <tr phx-click="task_clicked">
                  <td><%= task.title %></td>
                  <td><%= task.id %></td>
                  <%!-- <td><%= user.google_id %></td> --%>
                  <%!-- <td>
                  <%= user.token_expires_at
                  |> Timex.to_datetime("Asia/Dhaka")
                  |> Calendar.strftime("%Y/%m/%d %I:%M:%S") %>
                </td> --%>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("button_clicked", _params, socket) do
    socket = socket |> put_flash(:info, "Button Clicked")
    {:noreply, socket}
  end

  def handle_event("task_list_clicked", %{"tlid" => tlid}, socket) do
    socket =
      socket
      |> put_flash(:info, "Task List Clicked")
      |> assign(selected_task_list: tlid)

    # |> push_navigate(to: ~p"/tasks?id=#{gid}")
    IO.puts(inspect(socket))
    {:noreply, socket}
  end

  def handle_event("task_clicked", _params, socket) do
    socket = socket |> put_flash(:info, "Task Clicked")
    {:noreply, socket}
  end
end
