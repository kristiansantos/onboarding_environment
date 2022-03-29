defmodule ProductsManager.Contexts.Manager do
  import Ecto.Query, warn: false
  use QueryBuilder.Extension
  alias ProductsManager.Repo
  alias ProductsManager.Services.RedisService

  alias ProductsManager.Models.Product

  def list_products(params) when params == %{} do
    Repo.all(Product)
  end

  def list_products(params) do
    Product
    |> QueryBuilder.where(Map.to_list(params))
    |> Repo.all()
  end

  def get_product(id) do
    with {:ok, product} <- RedisService.get_by(id, "manager-product") do
      {:ok, product}
    else
      _ ->
        case Repo.get(Product, id) do
          nil -> {:error, :not_found}
          product -> cache_set({:ok, product})
        end
    end
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> cache_set()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> cache_set()
  end

  def delete_product(%Product{} = product) do
    RedisService.delete(product.id, "manager-product")
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp cache_set({:error, _}), do: {:error, :bad_request}

  defp cache_set({:ok, product}) do
    RedisService.set(product, "manager-product")
    {:ok, product}
  end
end
