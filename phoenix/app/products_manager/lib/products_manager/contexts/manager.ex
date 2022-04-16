defmodule ProductsManager.Contexts.Manager do
  import Ecto.Query, warn: false

  use QueryBuilder.Extension


  alias ProductsManager.Models.Product
  alias ProductsManager.Repo

  @elasticsearch_service Application.get_env(:elasticsearch, :service)
  @redis_service Application.get_env(:redis, :service)
  @source "product"

  def list_products(params) when params == %{} do
    case @elasticsearch_service.get_all(@source) do
      {:ok, products} -> products
      _ -> Repo.all(Product)
    end
  end

  def list_products(params) do
    params_to_list = Map.to_list(params)

    case @elasticsearch_service.get_all(params_to_list, @source) do
      {:ok, products} -> products

      _ ->
        Product
        |> QueryBuilder.where(params_to_list)
        |> Repo.all()
    end
  end

  def get_product(id) do
    with {:ok, product} <- @redis_service.get_by(id, @source) do
      {:ok, product}
    else
      _ ->
        case Repo.get(Product, id) do
          nil -> {:error, :not_found}
          product -> cached_and_indexed_data({:ok, product})
        end
    end
  end

  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> cached_and_indexed_data()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> cached_and_indexed_data()
  end

  def delete_product(%Product{} = product) do
    @elasticsearch_service.delete(product.id, @source)
    @redis_service.delete(product.id, @source)
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp cached_and_indexed_data({:error, _changeset} = error), do: error

  defp cached_and_indexed_data({:ok, product}) do
    @elasticsearch_service.create_or_update(product, @source)
    @redis_service.set(product, @source)
    {:ok, product}
  end
end
