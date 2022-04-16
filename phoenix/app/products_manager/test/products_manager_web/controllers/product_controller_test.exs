defmodule ProductsManagerWeb.ProductControllerTest do
  use ProductsManagerWeb.ConnCase

  alias ProductsManager.Contexts.Manager
  alias ProductsManager.Models.Product

  import Mox

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
      list_mock(%{})
      conn = get(conn, Routes.product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      create_update_mock()

      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      create_update_mock(@invalid_attrs)
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:fixture_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      create_update_mock(product)
      get_by_mock(product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      create_update_mock(product)
      get_by_mock(product)

      conn = put(conn, Routes.product_path(conn, :update, product), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:fixture_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      delete_mock(product.id)
      get_by_mock(product)

      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert response(conn, 204)
    end
  end

  defp fixture_product(_) do
    create_update_mock(@create_attrs)
    {:ok, product} = Manager.create_product(@create_attrs)
    %{product: product}
  end

  defp list_mock(_data \\ [], params) do
    if params == %{} do
      ElasticsearchBehaviourMock
      |> expect(:get_all, fn @source ->
        {:ok, _data}
      end)
    else
      ElasticsearchBehaviourMock
      |> expect(:get_all, fn _, @source ->
        {:ok, _data}
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

  defp create_update_mock(data \\ @create_attrs) do
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
