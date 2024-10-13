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
    file_path = System.get_env("GOOGLE_APPLICATION_CREDENTIALS")
    # IO.puts("Attempting to read file: #{file_path}")

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
        IO.puts("Error reading client secrets: #{reason}")
        raise "Failed to configure OAuth2 client: #{reason}"
    end
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(),
      scope:
        Enum.join(
          [
            "https://www.googleapis.com/auth/tasks",
            "https://www.googleapis.com/auth/spreadsheets",
            "https://www.googleapis.com/auth/spreadsheets.readonly",
            "https://www.googleapis.com/auth/drive",
            "https://www.googleapis.com/auth/drive.readonly",
            "https://www.googleapis.com/auth/drive.file"
          ],
          " "
        )
    )
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  def refresh_token(refresh_token) do
    client = client()

    params = [
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      client_id: client.client_id,
      client_secret: client.client_secret
    ]

    case OAuth2.Client.get_token(client, params) do
      {:ok, %{token: %{access_token: new_access_token}} = _client} ->
        {:ok, new_access_token}

      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end
end
