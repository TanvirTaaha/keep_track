defmodule KeepTrackWeb.GoogleAuthController do
  use KeepTrackWeb, :controller

  @doc """
  This action is reached via `/auth` and redirects to the Google OAuth2 provider.
  """
  def index(conn, _params) do
    redirect(conn,
      external: KeepTrack.Google.GoogleAuth.authorize_url!()
    )
  end

  def callback(conn, %{"code" => code}) do
    client = KeepTrack.Google.GoogleAuth.get_token!(code: code)

    conn
    |> put_session(:access_token, client.token.access_token)
    |> put_session(:refresh_token, client.token.refresh_token)
    |> redirect(to: "/")
  end
end
