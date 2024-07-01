defmodule DrawingApp.Drawings do
  alias DrawingApp.Repo
  alias DrawingApp.Drawing

  def get_or_create_drawing do
    case Repo.one(Drawing) do
      nil ->
        %Drawing{}
        |> Drawing.changeset(%{data: %{}})
        |> Repo.insert()
      drawing ->
        {:ok, drawing}
    end
  end

  def update_drawing(drawing, data) do
    drawing
    |> Drawing.changeset(%{data: data})
    |> Repo.update()
  end
end
