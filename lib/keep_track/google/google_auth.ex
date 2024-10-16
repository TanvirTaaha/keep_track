defmodule KeepTrack.Google.GoogleAuth do
  use OAuth2.Strategy

  def read_client_secrets(file_path) do
    with {:ok, body} <- File.read(file_path),
         {:ok, json} <- Poison.decode(body),
         %{"web" => config} <- json do
      {:ok, config}
    else
      {:error, :enoent} ->
        {:error, "File not found: #{file_path}"}

      {:error, %Poison.ParseError{}} ->
        {:error, "Invalid JSON in file: #{file_path}"}

      {:error, reason} when is_atom(reason) ->
        {:error, "File read error: #{:file.format_error(reason)}"}

      _ ->
        {:error, "Unexpected format in file: #{file_path}. Expected {'web': {...}}"}
    end
  end

  def client do
    file_path =
      System.get_env("GOOGLE_APPLICATION_CREDENTIALS") ||
        raise """
        environment variable GOOGLE_APPLICATION_CREDENTIALS is missing.
        """

    case read_client_secrets(file_path) do
      {:ok, config} ->
        OAuth2.Client.new(
          strategy: __MODULE__,
          client_id: config["client_id"],
          client_secret: config["client_secret"],
          redirect_uri: config["redirect_uris"] |> List.first(),
          site: "https://accounts.google.com",
          authorize_url: "/o/oauth2/auth",
          token_url: "/o/oauth2/token"
        )

      {:error, reason} ->
        dbg("Error reading client secrets: #{reason}")
        raise "Failed to configure OAuth2 client: #{reason}"
    end
  end

  def client(%KeepTrack.Accounts.User{} = user) do
    token =
      %{
        "access_token" => user.access_token,
        "refresh_token" => user.refresh_token
      }
      |> OAuth2.AccessToken.new()

    %{client() | token: token}
  end

  def client(_) do
    raise "Have to pass a %#{KeepTrack.Accounts.User}{} struct"
  end

  def authorize_url!(prompt_consent \\ false) do
    params = [
      scope:
        Enum.join(
          [
            "https://www.googleapis.com/auth/userinfo.email",
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/tasks",
            "https://www.googleapis.com/auth/spreadsheets",
            "https://www.googleapis.com/auth/spreadsheets.readonly",
            "https://www.googleapis.com/auth/drive",
            "https://www.googleapis.com/auth/drive.readonly",
            "https://www.googleapis.com/auth/drive.file"
          ],
          " "
        ),
      access_type: "offline"
    ]

    params = if prompt_consent, do: Keyword.put(params, :prompt, "consent"), else: params
    dbg(params)
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    case OAuth2.Client.get_token(client(), params, headers, opts) do
      {:ok, client} ->
        case Jason.decode(client.token.access_token) do
          {:ok, token_map} ->
            %{client | token: OAuth2.AccessToken.new(token_map)}

          {:error, reason} ->
            raise "Token parsing failed, reason#{reason}"
        end

      {:error, reason} ->
        raise "Couldn't get token #{reason}"
    end
  end

  def get_user_info(access_token) do
    url = "https://www.googleapis.com/oauth2/v2/userinfo"
    headers = [{"Authorization", "Bearer #{access_token}"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, user_info} ->
            dbg("In get_user_info:#{inspect(user_info)}")

            {:ok,
             %{
               id: user_info["id"],
               email: user_info["email"],
               name: user_info["name"],
               picture: user_info["picture"]
             }}

          {:error, _} ->
            {:error, "Failed to parse user info"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch user info. Status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  # + Strategy Callbacks
  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  # - Strategy Callbacks

  # def refresh_token(refresh_token) do
  #   client = client()
  #   dbg(client)

  #   params = [
  #     grant_type: "refresh_token",
  #     refresh_token: refresh_token,
  #     client_id: client.client_id,
  #     client_secret: client.client_secret
  #   ]

  #   case OAuth2.Client.get_token(client, params) do
  #     {:ok, %{token: %{access_token: new_access_token}} = client} ->
  #       dbg(client)
  #       {:ok, new_access_token}

  #     {:error, %{reason: reason}} ->
  #       {:error, reason}
  #   end
  # end

  def refresh_token(%KeepTrack.Accounts.User{} = user) do
    case OAuth2.Client.refresh_token(client(user), [], [], []) do
      {:ok, client} ->
        case Jason.decode(client.token.access_token) do
          {:ok, token_map} ->
            {:ok, %{client | token: OAuth2.AccessToken.new(token_map)}}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def refresh_token(_) do
    raise "Have to pass a %#{KeepTrack.Accounts.User}{} struct"
  end
end
