defmodule ProductsManager.ManagerTest do
  use ProductsManager.DataCase

  alias ProductsManager.Manager

  describe "products" do
    alias ProductsManager.Manager.Product

    @valid_attrs %{amount: 42, description: "some description", name: "some name", price: 120.5, sku: "some sku"}
    @update_attrs %{amount: 43, description: "some updated description", name: "some updated name", price: 456.7, sku: "some updated sku"}
    @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil}

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Manager.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Manager.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Manager.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Manager.create_product(@valid_attrs)
      assert product.amount == 42
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 120.5
      assert product.sku == "some sku"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Manager.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Manager.update_product(product, @update_attrs)
      assert product.amount == 43
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 456.7
      assert product.sku == "some updated sku"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Manager.update_product(product, @invalid_attrs)
      assert product == Manager.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Manager.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Manager.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Manager.change_product(product)
    end
  end
end
