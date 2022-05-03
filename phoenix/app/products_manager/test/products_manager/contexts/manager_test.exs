defmodule ProductsManager.Contexts.ManagerTest do
  use ProductsManager.DataCase
  use ProductsManager.TirexsHttpMock
  use ProductsManager.RedixMock

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
  @invalid_attrs %{
    amount: nil,
    description: nil,
    name: nil,
    price: nil,
    sku: nil,
    created_at: nil,
    updated_at: nil
  }
  @search_attrs %{sku: "ABC-DEFG-HJK", barcode: "A124BR66"}
  @search_attrs_not_match %{sku: "ABC-DEFG-AAAA", barcode: "A124B7R66"}

  setup :verify_on_exit!

  describe "list_products/0" do
    setup [:product_fixture]

    test "With success returns all products in elasticsearch", %{product: product} do
      tirexs_mock_get(:ok, product)

      assert Manager.list_products() == [product]
    end

    test "With success returns all products in database", %{product: product} do
      tirexs_mock_get(:error, product)

      assert Manager.list_products() == [product]
    end
  end

  describe "list_products/1" do
    setup [:product_fixture]

    test "With success returns search products in elasticsearch", %{product: product} do
      tirexs_mock_get(:ok, product)

      assert Manager.list_products(@search_attrs) == [product]
    end

    test "With success list_products/1 returns search products not match in elasticsearch" do
      tirexs_mock_get(:ok, [])

      assert Manager.list_products(@search_attrs_not_match) == []
    end

    test "With success returns search products in database", %{product: product} do
      tirexs_mock_get(:error, product)

      assert Manager.list_products(@search_attrs) == [product]
    end

    test "With success list_products/1 returns search products not match in database" do
      tirexs_mock_get(:error, [])

      assert Manager.list_products(@search_attrs_not_match) == []
    end
  end

  describe "get_product/1" do
    setup [:product_fixture]

    test "With success returns the product with the given id in redis", %{product: product} do
      redix_mock_command(:ok, "GET", product)

      assert {:ok, ^product} = Manager.get_product(product.id)
    end

    test "With error returns the product with the given id in database", %{product: product} do
      redix_mock_command(:ok, "GET", nil)
      cached_and_indexed_data_mock(product)

      assert {:ok, ^product} = Manager.get_product(product.id)
    end

    test "With error returns not found" do
      redix_mock_command(:error, "GET", nil)

      assert {:error, :not_found} = Manager.get_product("722a744bdf29eb0151000000")
    end
  end

  describe "create_product/1" do
    test "With sucess valid data creates a product" do
      cached_and_indexed_data_mock(@valid_attrs)

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
      cached_and_indexed_data_mock(@update_attrs)

      assert {:ok, %Product{} = product} = Manager.update_product(product, @update_attrs)
      assert product.amount == @update_attrs.amount
      assert product.description == @update_attrs.description
      assert product.name == @update_attrs.name
      assert product.price == @update_attrs.price
      assert product.sku == @update_attrs.sku
      assert product.barcode == @update_attrs.barcode
    end

    test "With error invalid data returns error changeset", %{product: product} do
      redix_mock_command(:ok, "GET", product)

      {:error, response} = Manager.update_product(product, @invalid_attrs)
      assert %Ecto.Changeset{valid?: false} = response

      assert {:ok, ^product} = Manager.get_product(product.id)
    end
  end

  describe "delete_product/1" do
    setup [:product_fixture]

    test "With success deletes the product", %{product: product} do
      tirexs_mock_delete()
      redix_mock_command(:ok, "DEL", product)

      assert {:ok, %Product{}} = Manager.delete_product(product)
    end
  end

  defp product_fixture(_) do
    cached_and_indexed_data_mock(@valid_attrs)
    {:ok, product} = Manager.create_product(@valid_attrs)

    %{product: product}
  end

  defp cached_and_indexed_data_mock(data) do
    tirexs_mock_put()
    redix_mock_command(:ok, "SET", data)
  end
end
