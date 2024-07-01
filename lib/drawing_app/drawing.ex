defmodule DrawingApp.Drawing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drawings" do
    field :data, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(drawing, attrs) do
    drawing
    |> cast(attrs, [:data])
    |> validate_required([])
  end
end
