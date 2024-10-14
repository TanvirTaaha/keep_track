defmodule KeepTrackWeb.Live.TasksLive do
  use KeepTrackWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Tasks",
        tasks: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="tasks">
      <div class="button-container">
        <button id="my-button" phx-click="button_clicked">Click Me</button>
      </div>
      <div id="taks_table">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <%!-- <th>Email</th> --%>
              <%!-- <th>Google ID</th> --%>
              <%!-- <th>Expire At</th> --%>
            </tr>
          </thead>
          <tbody>
            <%= for task <- @tasks do %>
              <tr phx-click="task_clicked">
                <td><%= task %></td>
                <%!-- <td><%= user.email %></td> --%>
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
    </div>
    """
  end
end
