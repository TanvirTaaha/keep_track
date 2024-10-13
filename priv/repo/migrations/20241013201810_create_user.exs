defmodule KeepTrack.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :google_id, :string
      add :email, :string
      add :name, :string
      add :access_token, :text
      add :refresh_token, :text
      add :token_expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user, [:email])
    create unique_index(:user, [:google_id])
  end
end
