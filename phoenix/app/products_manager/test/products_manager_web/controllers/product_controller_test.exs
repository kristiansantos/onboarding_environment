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

  setup :verify_on_exit!

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index/2" do
    setup [:product_fixture]

    test "Lists all products returns empty data", %{conn: conn} do
      tirexs_mock_get(:ok, [])

      response =
        conn
        |> get(Routes.product_path(conn, :index))
        |> json_response(200)

      assert response["data"] == []
    end

    test "Lists all products with data", %{conn: conn, product: product} do
      tirexs_mock_get(:ok, product)

      response =
        conn
        |> get(Routes.product_path(conn, :index))
        |> json_response(200)

      assert response["data"] == [
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

  describe "create/2" do
    test "Renders product when data is valid", %{conn: conn} do
      cached_and_indexed_data_mock(@create_attrs)

      response =
        conn
        |> post(Routes.product_path(conn, :create), product: @create_attrs)
        |> json_response(201)

      assert %{"id" => id} = response["data"]
      assert Repo.get(Product, id) != nil
    end

    test "Renders errors when data is invalid", %{conn: conn} do
      response =
        conn
        |> post(Routes.product_path(conn, :create), product: @invalid_attrs)
        |> json_response(422)

      assert response["errors"] == %{"name" => ["can't be blank"]}
    end
  end

  describe "show/2" do
    setup [:product_fixture]

    test "Renders product when id is valid", %{conn: conn, product: product} do
      redix_mock_command(:ok, "GET", product)

      conn = get(conn, Routes.product_path(conn, :show, product))

      assert response(conn, 200)
    end

    test "Renders errors when id not found", %{conn: conn, product: product} do
      redix_mock_command(:error, "GET", nil)

      product_not_found = %{product | id: "722a744bdf29eb0151000000"}

      conn = get(conn, Routes.product_path(conn, :show, product_not_found))

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
    end
  end

  describe "update/2" do
    setup [:product_fixture]

    test "Renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      cached_and_indexed_data_mock(product)
      redix_mock_command(:ok, "GET", product)

      response =
        conn
        |> put(Routes.product_path(conn, :update, product), product: @update_attrs)
        |> json_response(200)

      assert %{"id" => ^id} = response["data"]
      assert Repo.get(Product, id) != nil
    end

    test "Renders errors when data is not found", %{conn: conn, product: product} do
      redix_mock_command(:error, "GET", nil)

      product_not_found = %{product | id: "722a744bdf29eb0151000000"}

      conn =
        put(conn, Routes.product_path(conn, :update, product_not_found), product: @update_attrs)

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
    end

    test "Renders errors when data is invalid", %{conn: conn, product: product} do
      redix_mock_command(:ok, "GET", product)

      response =
        conn
        |> put(Routes.product_path(conn, :update, product), product: @invalid_attrs)
        |> json_response(422)

      assert response["errors"] == %{"name" => ["can't be blank"]}
    end
  end

  describe "delete/2" do
    setup [:product_fixture]

    test "Deletes chosen product", %{conn: conn, product: product} do
      redix_mock_command(:ok, "GET", product)
      redix_mock_command(:ok, "DEL", product)
      tirexs_mock_delete()

      conn = delete(conn, Routes.product_path(conn, :delete, product))

      assert response(conn, 204)
      assert Repo.get(Product, product.id) == nil
    end

    test "Deletes chosen product not found", %{conn: conn, product: product} do
      redix_mock_command(:error, "GET", nil)

      product_not_found = %{product | id: "722a744bdf29eb0151000000"}
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
