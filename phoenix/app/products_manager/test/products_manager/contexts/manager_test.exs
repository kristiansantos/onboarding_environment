defmodule ProductsManager.Contexts.ManagerTest do
  use ProductsManager.DataCase
  use ProductsManager.ElasticsearchMock
  use ProductsManager.RedisMock

  alias ProductsManager.Contexts.Manager
  alias ProductsManager.Models.Product

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

  describe "list_products/0" do
    setup [:product_fixture]

    test "With success returns all products in elasticsearch", %{product: product} do
      elasticsearch_list_mock(:no_search, :ok, [product], @source)

      assert Manager.list_products(%{}) == [product]
    end

    test "With success returns all products in database", %{product: product} do
      elasticsearch_list_mock(:no_search, :error, @source)

      assert Manager.list_products(%{}) == [product]
    end
  end

  describe "list_products/1" do
    setup [:product_fixture]

    test "With success returns search products in elasticsearch", %{product: product} do
      elasticsearch_list_mock(:search, :ok, [product], @source)

      assert Manager.list_products(@search_attrs) == [product]
    end

    test "With success list_products/1 returns search products not match in elasticsearch" do
      elasticsearch_list_mock(:search, :ok, @source)

      assert Manager.list_products(@search_attrs_not_match) == []
    end

    test "With success returns search products in database", %{product: product} do
      elasticsearch_list_mock(:search, :error, @source)

      assert Manager.list_products(@search_attrs) == [product]
    end

    test "With success list_products/1 returns search products not match in database" do
      elasticsearch_list_mock(:search, :error, @source)

      assert Manager.list_products(@search_attrs_not_match) == []
    end
  end

  describe "get_product/1" do
    setup [:product_fixture]

    test "With success returns the product with the given id in redis", %{product: product} do
      redis_get_by_mock(product)

      assert {:ok, get_product} = Manager.get_product(product.id)
    end

    test "With error returns the product with the given id in database", %{product: product} do
      create_update_mock(@valid_attrs)
      redis_get_by_mock({:error, :not_found})

      assert Manager.get_product(product.id) == {:ok, product}
    end

    test "With error returns not found", %{product: product} do
      redis_get_by_mock({:error, :not_found})

      assert {:error, :not_found} = Manager.get_product("722a744bdf29eb0151000000")
    end
  end

  describe "create_product/1" do
    test "With sucess valid data creates a product" do
      create_update_mock(@valid_attrs)

      assert {:ok, %Product{} = product} = Manager.create_product(@valid_attrs)
      assert product.amount == @valid_attrs.amount
      assert product.description == @valid_attrs.description
      assert product.name == @valid_attrs.name
      assert product.price == @valid_attrs.price
      assert product.sku == @valid_attrs.sku
      assert product.barcode == @valid_attrs.barcode
    end

    test "With invalid data returns error changeset" do
      {:error, response} = Manager.create_product(@invalid_attrs)
      assert %Ecto.Changeset{valid?: false} = response
    end
  end

  describe "update_product/1" do
    setup [:product_fixture]

    test "With success valid data updates the product", %{product: product} do
      create_update_mock(@update_attrs)

      assert {:ok, %Product{} = product} = Manager.update_product(product, @update_attrs)
      assert product.amount == @update_attrs.amount
      assert product.description == @update_attrs.description
      assert product.name == @update_attrs.name
      assert product.price == @update_attrs.price
      assert product.sku == @update_attrs.sku
      assert product.barcode == @update_attrs.barcode
    end

    test "With error invalid data returns error changeset", %{product: product} do
      create_update_mock(@invalid_attrss)

      {:error, response} = Manager.update_product(product, @invalid_attrs)
      assert %Ecto.Changeset{valid?: false} = response

      redis_get_by_mock({:error, :not_found})
      assert {:ok, product} == Manager.get_product(product.id)
    end
  end

  describe "delete_product/1" do
    setup [:product_fixture]

    test "With success deletes the product", %{product: product} do
      elasticsearch_delete_mock(@source, product.id)
      redis_delete_mock(@source, product.id)

      assert {:ok, %Product{}} = Manager.delete_product(product)
    end
  end

  defp product_fixture(_) do
    create_update_mock(@valid_attrs)
    {:ok, product} = Manager.create_product(@valid_attrs)

    %{product: product}
  end

  defp create_update_mock(data) do
    elasticsearch_create_update_mock(data)
    redis_set_mock(data)
  end
end
