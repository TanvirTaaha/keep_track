defmodule KeepTrackWeb.Live.HomeLive do
  use KeepTrackWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>KeepTrack</h1>
    """
  end
end
