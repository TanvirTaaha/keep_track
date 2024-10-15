defmodule KeepTrack.Repo.Migrations.CreateTasklists do
  use Ecto.Migration

  def change do
    create table(:tasklists) do
      add :etag, :string
      add :listid, :string
      add :kind, :string
      add :selfLink, :string
      add :title, :string
      add :updated, :string

      timestamps(type: :utc_datetime)
    end
  end
end
