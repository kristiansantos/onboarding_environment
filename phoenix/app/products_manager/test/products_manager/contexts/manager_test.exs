defmodule ProductsManager.Contexts.ManagerTest do
  use ProductsManager.DataCase

  alias ProductsManager.Contexts.Manager
  alias ProductsManager.Models.Product

  import Mox

  @valid_attrs %{
    amount: 42,
    description: "some description",
    name: "some name",
    price: 120.5,
    sku: "ABC-DEFG-HJK",
    barcode: "A124BR66"
  }
  @update_attrs %{
    amount: 43,
    description: "some updated description",
    name: "some updated name",
    price: 456.7,
    sku: "ABC-DEFG-FFF",
    barcode: "UP77BR56"
  }
  @search_attrs %{sku: "ABC-DEFG-HJK", barcode: "A124BR66"}
  @search_attrs_not_match %{sku: "ABC-DEFG-AAAA", barcode: "A124B7R66"}
  @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil}
  @source "product"

  describe "List products" do
    setup [:product_fixture]

    test "list_products/0 returns all products", %{product: product} do
      list_mock([product], %{})
      assert Manager.list_products(%{}) == [product]
    end

    test "list_products/1 returns search products", %{product: product} do
      list_mock([product], @search_attrs)
      assert Manager.list_products(@search_attrs) == [product]
    end

    test "list_products/1 returns search products not match", %{product: product} do
      list_mock(@invalid_attrs)

      assert Manager.list_products(@search_attrs_not_match) == []
    end
  end

  describe "Get product" do
    setup [:product_fixture]

    test "get_product/1 returns the product with given id", %{product: product} do
      get_by_mock(product)

      {:ok, get_product} = Manager.get_product(product.id)
      assert get_product == product
    end

    test "get_product/1 returns not found", %{product: product} do
      get_by_mock({:error, :not_found})

      assert {:error, :not_found} = Manager.get_product("722a744bdf29eb0151000000")
    end
  end

  describe "Create products" do
    setup [:product_fixture]

    test "create_product/1 with valid data creates a product", %{product: product} do
      assert product.amount == @valid_attrs.amount
      assert product.description == @valid_attrs.description
      assert product.name == @valid_attrs.name
      assert product.price == @valid_attrs.price
      assert product.sku == @valid_attrs.sku
      assert product.barcode == @valid_attrs.barcode
    end

    test "create_product/1 with invalid data returns error changeset" do
      {:error, response} = Manager.create_product(@invalid_attrs)
      assert %Ecto.Changeset{valid?: false} = response
    end
  end

  describe "Update product" do
    setup [:product_fixture]

    test "update_product/2 with valid data updates the product", %{product: product} do
      create_update_mock()

      assert {:ok, %Product{} = product} = Manager.update_product(product, @update_attrs)
      assert product.amount == @update_attrs.amount
      assert product.description == @update_attrs.description
      assert product.name == @update_attrs.name
      assert product.price == @update_attrs.price
      assert product.sku == @update_attrs.sku
      assert product.barcode == @update_attrs.barcode
    end

    test "update_product/2 with invalid data returns error changeset", %{product: product} do
      get_by_mock(product)

      {:error, response} = Manager.update_product(product, @invalid_attrs)
      assert %Ecto.Changeset{valid?: false} = response

      {:ok, get_product} = Manager.get_product(product.id)
      assert product == get_product
    end
  end

  describe "Delete product" do
    setup [:product_fixture]

    test "delete_product/1 deletes the product", %{product: product} do
      delete_mock(product.id)
      assert {:ok, %Product{}} = Manager.delete_product(product)
    end
  end

  describe "Changeset product" do
    setup [:product_fixture]

    test "change_product/1 returns a product changeset", %{product: product} do
      assert %Ecto.Changeset{} = Manager.change_product(product)
    end
  end

  defp product_fixture(_) do
    create_update_mock()

    {:ok, product} = Manager.create_product(@valid_attrs)

    %{product: product}
  end

  defp list_mock(data \\ [], params) do
    if params == %{} do
      ElasticsearchBehaviourMock
      |> expect(:get_all, fn @source ->
        {:ok, data}
      end)
    else
      ElasticsearchBehaviourMock
      |> expect(:get_all, fn _, @source ->
        {:ok, data}
      end)
    end
  end

  defp get_by_mock({:error, :not_found}) do
    RedisBehaviourMock
    |> expect(:get_by, fn _, _ ->
      {:error, :not_found}
    end)
  end

  defp get_by_mock(data) do
    RedisBehaviourMock
    |> expect(:get_by, fn _, _ ->
      {:ok, data}
    end)
  end

  defp create_update_mock(data \\ @valid_attrs) do
    ElasticsearchBehaviourMock
    |> expect(:create_or_update, fn _, _ ->
      {:ok, data}
    end)

    RedisBehaviourMock
    |> expect(:set, fn _, _ ->
      data
      |> :erlang.term_to_binary()
      |> Base.encode16()
    end)
  end

  defp delete_mock(id) do
    ElasticsearchBehaviourMock
    |> expect(:delete, fn id, @source ->
      :ok
    end)

    RedisBehaviourMock
    |> expect(:delete, fn id, @source ->
      :ok
    end)
  end
end
