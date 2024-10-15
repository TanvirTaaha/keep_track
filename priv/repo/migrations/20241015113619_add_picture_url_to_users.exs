defmodule KeepTrack.Repo.Migrations.AddPictureUrlToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :picture_url, :string
    end
  end
end
