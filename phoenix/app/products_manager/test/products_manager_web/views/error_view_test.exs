defmodule ProductsManagerWeb.ErrorViewTest do
  use ProductsManagerWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "Renders 404.json" do
    assert render(ProductsManagerWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "Renders 500.json" do
    assert render(ProductsManagerWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
