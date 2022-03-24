defmodule ProductsManager.Manager do
  import Ecto.Query, warn: false
  use QueryBuilder.Extension
  alias ProductsManager.Repo

  alias ProductsManager.Manager.Product

  def list_products(params) when params == %{} do
    Repo.all(Product)
  end

  def list_products(params) do
    Product
    |> QueryBuilder.where(Map.to_list(params))
    |> Repo.all()
  end

  def get_product(id) do
    case Repo.get(Product, id) do
      nil -> {:error, :not_found}
      product -> {:ok, product}
    end
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
