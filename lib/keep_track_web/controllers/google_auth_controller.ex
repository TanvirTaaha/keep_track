defmodule KeepTrackWeb.GoogleAuthController do
  use KeepTrackWeb, :controller
  alias KeepTrack.Google.GoogleAuth
  alias KeepTrack.Accounts

  @doc """
  This action is reached via `/auth` and redirects to the Google OAuth2 provider.
  """
  def index(conn, %{"prompt_consent" => _}), do: handle_index(conn, true)
  def index(conn, _params), do: handle_index(conn, false)

  defp handle_index(conn, prompt_consent) do
    dbg(prompt_consent)
    google_url = KeepTrack.Google.GoogleAuth.authorize_url!(prompt_consent)
    dbg(google_url)
    # redirect(conn, to: "/")
    redirect(conn, external: google_url)
  end

  def callback(conn, %{"code" => code}) do
    with %OAuth2.Client{} = client <- GoogleAuth.get_token!(code: code),
         {:ok, user_info} <- GoogleAuth.get_user_info(client.token.access_token),
         {:ok, user} <- upsert_user(user_info, client.token),
         conn <- put_session(conn, :user_id, user.id) do
      IO.puts("inside callback")
      dbg(code)
      # IO.puts("client:#{inspect(client)}")
      dbg(client)
      # IO.puts("user_info:#{inspect(user_info)}")
      dbg(user_info)
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
      token_expires_at: DateTime.from_unix!(token.expires_at),
      picture_url: user_info.picture
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
      token_expires_at: DateTime.from_unix!(token.expires_at),
      picture_url: user_info.picture
    })
  end
end
