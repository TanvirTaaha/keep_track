defmodule KeepTrack.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :google_id, :string
    field :email, :string
    field :access_token, :string
    field :refresh_token, :string
    field :token_expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:google_id, :email, :name, :access_token, :refresh_token, :token_expires_at])
    |> validate_required([
      :google_id,
      :email,
      :name,
      :access_token,
      # :refresh_token,
      :token_expires_at
    ])
    |> unique_constraint(:email)
    |> unique_constraint(:google_id)
  end
end
