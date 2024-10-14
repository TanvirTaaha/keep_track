defmodule KeepTrackWeb.PageController do
  use KeepTrackWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # dbg(conn)

    conn
    |> assign(:page_title, "Home")
    |> render(:home, layout: false)
  end

  def dummy(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    # dbg(conn)
    render(conn, :dummy)
  end
end
