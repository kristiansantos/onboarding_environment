defmodule ProductsManager.Contexts.Manager do
  import Ecto.Query, warn: false

  use QueryBuilder.Extension


  alias ProductsManager.Models.Product
  alias ProductsManager.Repo
  alias ProductsManager.Services.Redis
  alias ProductsManager.Services.Elasticsearch


  @source "product"

  def list_products(params) when params == %{} do
    case Elasticsearch.get_all(@source) do
      {:ok, products} -> products
      _ -> Repo.all(Product)
    end
  end

  def list_products(params) do
    params_to_list = Map.to_list(params)

    case Elasticsearch.get_all(params_to_list, @source) do
      {:ok, products} -> products

      _ ->
        Product
        |> QueryBuilder.where(params_to_list)
        |> Repo.all()
    end
  end

  def get_product(id) do
    with {:ok, product} <- Redis.get_by(id, @source) do
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
    Elasticsearch.delete(product.id, @source)
    Redis.delete(product.id, @source)
    Repo.delete(product)
  end

  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp cached_and_indexed_data({:error, _}), do: {:error, :bad_request}

  defp cached_and_indexed_data({:ok, product}) do
    Elasticsearch.create_or_update(product, @source)
    Redis.set(product, @source)
    {:ok, product}
  end
end
