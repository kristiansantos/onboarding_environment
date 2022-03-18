defmodule ProductsManagerWeb.ProductController do
  use ProductsManagerWeb, :controller

  alias ProductsManager.Manager
  alias ProductsManager.Manager.Product

  action_fallback ProductsManagerWeb.FallbackController

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
    product = Manager.get_product!(id)
    render(conn, "show.json", product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Manager.get_product!(id)

    with {:ok, %Product{} = product} <- Manager.update_product(product, product_params) do
      render(conn, "show.json", product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Manager.get_product!(id)

    with {:ok, %Product{}} <- Manager.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
