defmodule ProductsManagerWeb.ProductControllerTest do
  use ProductsManagerWeb.ConnCase
  use ProductsManager.ElasticsearchMock
  use ProductsManager.RedisMock

  alias ProductsManager.Contexts.Manager
  alias ProductsManager.Models.Product
  alias ProductsManager.Repo

  @create_attrs %{
    amount: 42,
    description: "some description",
    name: "some name",
    price: 120,
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
  @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil}
  @source "product"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      elasticsearch_list_mock(%{}, @source)

      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create" do
    test "renders product when data is valid", %{conn: conn} do
      create_update_mock(@create_attrs)
      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Repo.get(Product, id) != nil
    end

    test "renders errors when data is invalid", %{conn: conn} do
      create_update_mock(@invalid_attrs)
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update" do
    setup [:fixture_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      create_update_mock(@create_attrs)
      redis_get_by_mock(product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]
      assert Repo.get(Product, id) != nil
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      create_update_mock(@create_attrs)
      redis_get_by_mock(product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete" do
    setup [:fixture_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      redis_get_by_mock(product)
      elasticsearch_delete_mock(product.id, @source)
      redis_delete_mock(product.id, @source)

      conn = delete(conn, Routes.product_path(conn, :delete, product))

      assert response(conn, 204)
      assert Repo.get(Product, product.id) == nil
    end
  end

  defp fixture_product(_) do
    create_update_mock(@create_attrs)
    {:ok, product} = Manager.create_product(@create_attrs)

    %{product: product}
  end

  defp create_update_mock(data) do
    elasticsearch_create_update_mock(data)
    redis_set_mock(data)
  end
end
