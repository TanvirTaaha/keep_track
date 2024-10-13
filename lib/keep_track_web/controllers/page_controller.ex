defmodule KeepTrackWeb.PageController do
  use KeepTrackWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    dbg(conn)
    render(conn, :home, layout: false)
  end

  def dummy(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    IO.puts(inspect(conn))
    render(conn, :dummy)
  end
end
