defmodule ProductsManagerWeb.FallbackController do
  use ProductsManagerWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ProductsManagerWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ProductsManagerWeb.ErrorView)
    |> render("404.json")
  end

  def call(conn, {:error, :internal_server_error}) do
    conn
    |> put_status(500)
    |> put_view(ProductsManagerWeb.ErrorView)
    |> render(:"500")
  end

  def call(conn, {:error, :bad_request, result}) do
    conn
    |> put_status(400)
    |> put_view(ProductsManagerWeb.ErrorView)
    |> render(:"400", result: result)
  end

end
