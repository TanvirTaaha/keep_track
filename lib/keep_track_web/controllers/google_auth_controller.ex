defmodule KeepTrackWeb.GoogleAuthController do
  use KeepTrackWeb, :controller
  alias KeepTrack.Google.GoogleAuth
  alias KeepTrack.Accounts

  @doc """
  This action is reached via `/auth` and redirects to the Google OAuth2 provider.
  """
  def index(conn, _params) do
    redirect(conn,
      external: KeepTrack.Google.GoogleAuth.authorize_url!()
    )
  end

  def callback(conn, %{"code" => code}) do
    with %OAuth2.Client{} = client <- GoogleAuth.get_token!(code: code),
         {:ok, user_info} <- GoogleAuth.get_user_info(client.token.access_token),
         {:ok, user} <- upsert_user(user_info, client.token),
         conn <- put_session(conn, :user_id, user.id) do
      redirect(conn, to: "/")
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, "Authentication failed: #{reason}")
        |> redirect(to: "/")
    end
  end

  defp upsert_user(user_info, token) do
    dbg(user_info)
    dbg(token)

    Accounts.get_user_by_google_id(user_info.id)
    |> case do
      nil ->
        create_user(user_info, token)

      user ->
        update_user(user, user_info, token)
    end
  end

  defp create_user(user_info, token) do
    %{
      google_id: user_info.id,
      email: user_info.email,
      name: user_info.name,
      access_token: token.access_token,
      refresh_token: token.refresh_token,
      token_expires_at: DateTime.from_unix!(token.expires_at)
    }
    |> Accounts.create_user()
  end

  defp update_user(user, user_info, token) do
    user
    |> Accounts.update_user(%{
      email: user_info.email,
      name: user_info.name,
      access_token: token.access_token,
      refresh_token: token.refresh_token,
      token_expires_at: DateTime.from_unix!(token.expires_at)
    })
  end
end
