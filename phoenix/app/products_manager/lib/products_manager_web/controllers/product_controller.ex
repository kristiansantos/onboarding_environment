defmodule ProductsManagerWeb.ProductController do
  use ProductsManagerWeb, :controller

  alias ProductsManager.Contexts.Manager
  alias ProductsManager.Models.Product

  action_fallback ProductsManagerWeb.FallbackController

  plug :set_product when action in [:show, :update, :delete]

  def index(conn, params) do
    products = Manager.list_products(params)
    render(conn, "index.json", products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Manager.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.product_path(conn, :show, product))
      |> render("show.json", product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.json", product: conn.assigns[:product])
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with {:ok, %Product{} = product} <-
           Manager.update_product(conn.assigns[:product], product_params) do
      render(conn, "show.json", product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Product{}} <- Manager.delete_product(conn.assigns[:product]) do
      send_resp(conn, :no_content, "")
    end
  end

  defp set_product(conn, _) do
    with {:ok, %Product{} = product} <- Manager.get_product(conn.params["id"]) do
      assign(conn, :product, product)
    else
      {:error, :not_found} ->
        halt(send_resp(conn, :not_found, "Not Found"))
    end
  end
end
