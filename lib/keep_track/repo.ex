defmodule KeepTrack.Repo do
  use Ecto.Repo,
    otp_app: :keep_track,
    adapter: Ecto.Adapters.SQLite3
end
