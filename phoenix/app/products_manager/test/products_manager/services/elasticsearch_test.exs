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

  def data_fixture() do
    {:ok, 201, data} = Elasticsearch.create_or_update(@valid_attrs, @source)

    :timer.sleep(2000)
    data
  end

  describe "get_all" do
    test "get_all/1 only source" do
      data = data_fixture()
      assert {:ok, [data]} = Elasticsearch.get_all(@source)
    end

    test "get_all/2 filter and source" do
      data = data_fixture()

      assert {:ok, [data]} =
               Elasticsearch.get_all([name: "name_test", barcode: "UP77BR56"], @source)
    end
  end

  describe "create_or_update" do
    test "create_or_update/1 create with valid data" do
      assert Integer.to_string(@valid_attrs.id) == data_fixture()[:_id]
    end

    test "create_or_update/1 update with valid data" do
      assert {:ok, 201, data} = Elasticsearch.create_or_update(@update_attrs, @source)
    end

    test "create_or_update/1 with invalid data" do
      assert_raise KeyError, fn -> Elasticsearch.create_or_update(@invalid_attrs, @source) end
    end
  end

  describe "delete" do
    test "delete/1 with valid id" do
      data_fixture()
      assert {:ok, 200, response} = Elasticsearch.delete(@valid_attrs.id, @source)
    end

    test "delete/1 with invalid id" do
      data = data_fixture()

      assert {:error, 404, %{}} = Elasticsearch.delete("01020305", @source)
    end
  end
end
