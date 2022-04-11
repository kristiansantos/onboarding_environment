defmodule ProductsManager.ElasticSearchTest do
  use ProductsManager.DataCase

  alias ProductsManager.Services.Elasticsearch

  @valid_attrs %{
    id: Enum.random(0..255),
    amount: 42,
    description: "some description",
    name: "name_test",
    price: 120.5,
    sku: "ABC-DEFG-HJK",
    barcode: "A124BR66"
  }
  @update_attrs %{
    id: Enum.random(0..255),
    amount: 43,
    description: "some updated description",
    name: "some_updated_name",
    price: 456.7,
    sku: "ABC-DEFG-FFF",
    barcode: "UP77BR56"
  }
  @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil}
  @source "elasticsearch_test"

  describe "get_all" do
    setup [:data_fixture]

    test "get_all/1 only source" do
      assert {:ok, [data]} = Elasticsearch.get_all(@source)
    end

    test "get_all/2 filter and source" do
      assert {:ok, [data]} =
               Elasticsearch.get_all([name: "name_test", barcode: "UP77BR56"], @source)
    end
  end

  describe "create_or_update" do
    setup [:data_fixture]

    test "create_or_update/1 create with valid data", data do
      assert Integer.to_string(@valid_attrs.id) == data[:_id]
    end

    test "create_or_update/1 update with valid data" do
      assert {:ok, 201, data} = Elasticsearch.create_or_update(@update_attrs, @source)
    end

    test "create_or_update/1 with invalid data" do
      assert_raise KeyError, fn -> Elasticsearch.create_or_update(@invalid_attrs, @source) end
    end
  end

  describe "delete" do
    setup [:data_fixture]

    test "delete/1 with valid id" do
      assert {:ok, 200, response} = Elasticsearch.delete(@valid_attrs.id, @source)
    end

    test "delete/1 with invalid id" do
      assert {:error, 404, %{}} = Elasticsearch.delete("01020305", @source)
    end
  end

  defp data_fixture(_) do
    with {:ok, 201, data} <- Elasticsearch.create_or_update(@valid_attrs, @source) do
      :timer.sleep(2000)
      data
    end
  end
end
