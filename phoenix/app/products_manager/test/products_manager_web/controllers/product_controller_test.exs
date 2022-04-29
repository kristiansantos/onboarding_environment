defmodule ProductsManagerWeb.ProductControllerTest do
  use ProductsManagerWeb.ConnCase
  use ProductsManager.TirexsHttpMock
  use ProductsManager.RedixMock

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

  setup :verify_on_exit!

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:product_fixture]

    test "lists all products returns empty data", %{conn: conn} do
      tirexs_mock_get(:ok, [])

      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all products with data", %{conn: conn, product: product} do
      tirexs_mock_get(:ok, product)

      conn = get(conn, Routes.product_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => product.id,
                 "amount" => product.amount,
                 "description" => product.description,
                 "name" => product.name,
                 "price" => product.price,
                 "sku" => product.sku,
                 "barcode" => product.barcode
               }
             ]
    end
  end

  describe "create" do
    test "renders product when data is valid", %{conn: conn} do
      cached_and_indexed_data_mock(@create_attrs)

      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Repo.get(Product, id) != nil
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] == %{"name" => ["can't be blank"]}
    end
  end

  describe "show" do
    setup [:product_fixture]

    test "renders product when id is valid", %{conn: conn, product: product} do
      redix_mock_command(:ok, "GET", product)

      conn = get(conn, Routes.product_path(conn, :show, product))

      assert response(conn, 200)
    end

    test "renders errors when id not found", %{conn: conn, product: product} do
      redix_mock_command(:error, "GET", nil)

      product_not_found = Map.replace(product, :id, "722a744bdf29eb0151000000")
      conn = get(conn, Routes.product_path(conn, :show, product_not_found))

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
    end
  end

  describe "update" do
    setup [:product_fixture]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      cached_and_indexed_data_mock(product)
      redix_mock_command(:ok, "GET", product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]
      assert Repo.get(Product, id) != nil
    end

    test "renders errors when data is not found", %{conn: conn, product: product} do
      redix_mock_command(:error, "GET", nil)

      product_not_found = Map.replace(product, :id, "722a744bdf29eb0151000000")

      conn =
        put(conn, Routes.product_path(conn, :update, product_not_found), product: @update_attrs)

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      redix_mock_command(:ok, "GET", product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] == %{"name" => ["can't be blank"]}
    end
  end

  describe "delete" do
    setup [:product_fixture]

    test "deletes chosen product", %{conn: conn, product: product} do
      redix_mock_command(:ok, "GET", product)
      redix_mock_command(:ok, "DEL", product)
      tirexs_mock_delete()

      conn = delete(conn, Routes.product_path(conn, :delete, product))

      assert response(conn, 204)
      assert Repo.get(Product, product.id) == nil
    end

    test "deletes chosen product not found", %{conn: conn, product: product} do
      redix_mock_command(:error, "GET", nil)

      product_not_found = Map.replace(product, :id, "722a744bdf29eb0151000000")
      conn = delete(conn, Routes.product_path(conn, :delete, product_not_found))

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
    end
  end

  defp product_fixture(_) do
    cached_and_indexed_data_mock(@create_attrs)

    {:ok, product} = Manager.create_product(@create_attrs)

    %{product: product}
  end

  defp cached_and_indexed_data_mock(data) do
    tirexs_mock_put()
    redix_mock_command(:ok, "SET", data)
  end
end
