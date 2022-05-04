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

  @source "data_source"

  setup :verify_on_exit!

  describe "get_all/1" do
    test "With sucess" do
      tirexs_mock_get(:ok, @valid_attrs)

      assert {:ok, [@valid_attrs]} == Elasticsearch.get_all(@source)
    end
  end

  describe "get_all/2" do
    test "With sucess and apply filters" do
      tirexs_mock_get(:ok, @valid_attrs)

      assert {:ok, [@valid_attrs]} ==
               Elasticsearch.get_all(@source, name: "name_test", barcode: "UP77BR56")
    end
  end

  describe "create_or_update/2" do
    test "With sucess to check url" do
      assert "/products_manager_test/data_source/#{@valid_attrs.id}" ==
               "#{Application.get_env(:elasticsearch, :index)}/#{@source}/#{@valid_attrs.id}"
    end
  end

  describe "delete/2" do
    test "With sucess to check url" do
      assert "/products_manager_test/data_source/#{@valid_attrs.id}" ==
               "#{Application.get_env(:elasticsearch, :index)}/#{@source}/#{@valid_attrs.id}"
    end
  end

  describe "delete_all/0" do
    test "With sucess to check url" do
      assert "/products_manager_test" == "#{Application.get_env(:elasticsearch, :index)}"
    end
  end
end
