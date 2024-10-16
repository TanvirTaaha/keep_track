defmodule KeepTrackWeb.Live.TasksLive do
  use KeepTrackWeb, :live_view
  alias KeepTrack.Accounts
  alias KeepTrack.Google.Tasks
  alias KeepTrack.Agents

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Tasks",
        task_lists: [],
        tasks: [],
        selected_task_list: nil
      )

    dbg("Mount called")
    Agents.UserStateAgent.start_link(nil)
    {:ok, socket}
  end

  def handle_params(%{"id" => gid, "tlid" => tlid}, _uri, socket) do
    unless Map.has_key?(socket.assigns, :tlid) do
      send(self(), {:fetch_tasks, gid, tlid})
    end

    {:noreply, socket}
  end

  def handle_params(%{"id" => gid}, _uri, socket) do
    unless Map.has_key?(socket.assigns, :gid) do
      send(self(), {:fetch_tasklists, gid})
    end

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info({:fetch_tasklists, gid}, socket) do
    socket =
      case dbg(Accounts.get_user_by_google_id(gid)) do
        nil ->
          socket
          |> put_flash(:error, "No user found")
          |> push_navigate(to: ~p"/")

        user ->
          dbg("Matched with user")
          dbg(Agents.UserStateAgent.update(user))
          task_lists = Tasks.list_task_lists(user)
          dbg(task_lists)

          socket
          |> assign(task_lists: task_lists, gid: gid)
      end

    {:noreply, socket}
  end

  def handle_info({:fetch_tasks, gid, tlid}, socket) do
    socket =
      if Map.has_key?(socket.assigns, :gid) do
        socket
      else
        {:noreply, socket} = handle_info({:fetch_tasklists, gid}, socket)
        socket
      end

    dbg("tasklist checked, fetching tasks")

    tasks =
      Tasks.list_tasks(Agents.UserStateAgent.value(), tlid)
      |> Enum.frequencies_by(&(&1.title |> String.split() |> List.first()))

    socket =
      assign(socket,
        selected_task_list: tlid,
        tasks: dbg(tasks)
      )

    dbg(socket)
    {:noreply, socket}
  end

  def render(assigns) do
    dbg("Render called")

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
      <%= unless Enum.empty?(@tasks) do %>
        <div class="table_title">Tasks</div>
        <div id="tasks_table">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Count</th>
                <%!-- <th>Google ID</th> --%>
                <%!-- <th>Expire At</th> --%>
              </tr>
            </thead>
            <tbody>
              <%= for task <- @tasks do %>
                <tr phx-click="task_clicked">
                  <td><%= elem(task, 0) %></td>
                  <td><%= elem(task, 1) %></td>
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
      <% else %>
        <div class="empty_table">
          <span>No entry found</span>
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
      |> push_patch(to: ~p"/tasks?id=#{socket.assigns.gid}&tlid=#{tlid}")

    dbg(socket)
    {:noreply, socket}
  end

  def handle_event("task_clicked", _params, socket) do
    socket = socket |> put_flash(:info, "Task Clicked")
    {:noreply, socket}
  end
end
