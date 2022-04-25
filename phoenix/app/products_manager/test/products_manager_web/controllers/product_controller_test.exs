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
    setup [:fixture_product]

    test "lists all products without data", %{conn: conn} do
      elasticsearch_list_mock(:no_search, :ok, @source)

      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all products with data", %{conn: conn, product: product} do
      elasticsearch_list_mock(:no_search, :ok, [product], @source)

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
      create_update_mock(@create_attrs)
      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert Repo.get(Product, id) != nil
    end

    test "renders errors when data is invalid", %{conn: conn} do
      create_update_mock(@invalid_attrs)
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] == %{"name" => ["can't be blank"]}
    end
  end

  describe "show" do
    setup [:fixture_product]

    test "renders product when id is valid", %{conn: conn, product: product} do
      redis_get_by_mock(product)

      conn = get(conn, Routes.product_path(conn, :show, product))

      assert response(conn, 200)
    end

    test "renders errors when id not found", %{conn: conn, product: product} do
      redis_get_by_mock({:error, :not_found})

      product_not_found = Map.replace(product, :id, "722a744bdf29eb0151000000")
      conn = get(conn, Routes.product_path(conn, :show, product_not_found))

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
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

    test "renders errors when data is not found", %{conn: conn, product: product} do
      create_update_mock(product)
      redis_get_by_mock({:error, :not_found})

      product_not_found = Map.replace(product, :id, "722a744bdf29eb0151000000")

      conn =
        put(conn, Routes.product_path(conn, :update, product_not_found), product: @update_attrs)

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      create_update_mock(@create_attrs)
      redis_get_by_mock(product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] == %{"name" => ["can't be blank"]}
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

    test "deletes chosen product not found", %{conn: conn, product: product} do
      redis_get_by_mock({:error, :not_found})
      elasticsearch_delete_mock(product.id, @source)
      redis_delete_mock(product.id, @source)

      product_not_found = Map.replace(product, :id, "722a744bdf29eb0151000000")
      conn = delete(conn, Routes.product_path(conn, :delete, product_not_found))

      assert conn.resp_body == "Not Found"
      assert response(conn, 404)
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
