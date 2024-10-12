defmodule KeepTrackWeb.AuthController do
  use KeepTrackWeb, :controller
  plug Ueberauth

  # def init(default), do: default

  # def call(conn, default) do
  #   assign(conn, :locale, default)
  # end
end
