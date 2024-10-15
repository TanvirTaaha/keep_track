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
      dbg(code)
      dbg(client)
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

  def access_token_for(%Accounts.User{} = user) do
    # Check if the token is still valid
    if DateTime.compare(DateTime.utc_now(), user.token_expires_at) == :lt do
      {:ok, user.access_token}
    else
      # If expired, use the refresh token to get a new access token
      dbg("Token expired")

      case GoogleAuth.refresh_token(user) do
        {:ok, client} ->
          dbg(update_new_token_for(user, client.token))
          {:ok, client.token.access_token}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def access_token_for(_user) do
    raise "Have to pass a user schema struct"
  end

  def access_token_for!(%Accounts.User{} = user) do
    case access_token_for(user) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end

  defp update_new_token_for(%Accounts.User{} = user, %OAuth2.AccessToken{} = token) do
    user
    |> Accounts.update_user(%{
      access_token: token.access_token,
      token_expires_at: DateTime.from_unix!(token.expires_at)
    })
  end
end
