defmodule ProductsManager.ElasticSearchTest do
  use ProductsManager.DataCase
  use ProductsManager.TirexsHttpMock

  alias ProductsManager.Services.Elasticsearch

  @valid_attrs %{
    id: Enum.random(0..255),
    amount: 42,
    description: "some description",
    name: "name_test",
    price: 120.5,
    sku: "ABC-DEFG-HJK",
    barcode: "A124BR66",
    created_at: DateTime.to_iso8601(DateTime.utc_now()),
    updated_at: DateTime.to_iso8601(DateTime.utc_now())
  }
  @update_attrs %{
    id: Enum.random(0..255),
    amount: 43,
    description: "some updated description",
    name: "some_updated_name",
    price: 456.7,
    sku: "ABC-DEFG-FFF",
    barcode: "UP77BR56",
    created_at: DateTime.to_iso8601(DateTime.utc_now()),
    updated_at: DateTime.to_iso8601(DateTime.utc_now())
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
  @source "product"

  setup :verify_on_exit!

  describe "get_all" do
    setup [:data_fixture]

    test "get_all/1 only source" do
      tirexs_mock_get(:ok, @valid_attrs)

      assert {:ok, [@valid_attrs]} == Elasticsearch.get_all(@source)
    end

    test "get_all/2 filter and source" do
      tirexs_mock_get(:ok, @valid_attrs)

      assert {:ok, [@valid_attrs]} ==
               Elasticsearch.get_all(@source, name: "name_test", barcode: "UP77BR56")
    end
  end

  defp data_fixture(_) do
    tirexs_mock_put()

    with {:ok, 201, data} <- Elasticsearch.create_or_update(@source, @valid_attrs) do
      @valid_attrs
    end
  end
end
