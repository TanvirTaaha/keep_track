defmodule KeepTrack.Repo.Migrations.RenameUserToUsers do
  use Ecto.Migration

  def change do
    rename table(:user), to: table(:users)
  end
end
