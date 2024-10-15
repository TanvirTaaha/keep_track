defmodule KeepTrack.Task.TaskList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasklists" do
    field :title, :string
    field :kind, :string
    field :etag, :string
    field :listid, :string
    field :selfLink, :string
    field :updated, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_list, attrs) do
    task_list
    |> cast(attrs, [:etag, :listid, :kind, :selfLink, :title, :updated])
    |> validate_required([:etag, :listid, :kind, :selfLink, :title, :updated])
  end
end
