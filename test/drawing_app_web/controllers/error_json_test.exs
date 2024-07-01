defmodule DrawingAppWeb.ErrorJSONTest do
  use DrawingAppWeb.ConnCase, async: true

  test "renders 404" do
    assert DrawingAppWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert DrawingAppWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
