defmodule DrawingApp.Repo.Migrations.CreateDrawings do
  use Ecto.Migration

  def change do
    create table(:drawings) do
      add :data, :map

      timestamps(type: :utc_datetime)
    end
  end
end
