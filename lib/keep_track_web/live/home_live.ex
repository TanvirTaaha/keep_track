defmodule KeepTrackWeb.Live.HomeLive do
  alias KeepTrack.Accounts
  use KeepTrackWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Home",
        users: Accounts.list_users()
      )

    {:ok, socket, temporary_assigns: [users: []]}
  end

  def render(assigns) do
    ~H"""
    <div id="home">
      <div class="button-container">
        <button id="my-button" phx-click="button_clicked">Click Me</button>
      </div>
      <div id="user_table">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Google ID</th>
              <th>Expire At</th>
            </tr>
          </thead>
          <tbody>
            <%= for user <- @users do %>
              <tr phx-click="user_clicked" phx-value-gid={"#{user.google_id}"}>
                <td><%= user.name %></td>
                <td><%= user.email %></td>
                <td><%= user.google_id %></td>
                <td>
                  <%= user.token_expires_at
                  |> Timex.to_datetime("Asia/Dhaka")
                  |> Calendar.strftime("%Y/%m/%d %I:%M:%S") %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def handle_event("button_clicked", _params, socket) do
    IO.puts("Button clicked!")
    send(self(), :list_all_users)
    {:noreply, socket}
  end

  def handle_event("user_clicked", %{"gid" => gid}, socket) do
    IO.puts("User clicked!")
    send(self(), {:fetch_user, gid})
    # IO.puts(inspect(Accounts.get_user_by_google_id(gid)))
    {:noreply, socket}
  end

  @spec handle_info(:list_all_users | {:fetch_user, any()}, any()) :: {:noreply, any()}
  def handle_info(:list_all_users, socket) do
    IO.puts(":list_all_users msg received")

    socket =
      assign(socket,
        users: Accounts.list_users()
      )

    {:noreply, socket}
  end

  def handle_info({:fetch_user, gid}, socket) do
    IO.puts("inside handle_info msg received, gid:#{gid}")

    socket =
      case Accounts.get_user_by_google_id(gid) do
        nil ->
          socket
          |> put_flash(:error, "No user found")

        user ->
          IO.puts(inspect(user))

          socket
      end

    {:noreply, socket}
  end
end
