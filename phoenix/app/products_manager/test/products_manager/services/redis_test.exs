defmodule ProductsManager.RedisTest do
  use ProductsManager.DataCase
  use ProductsManager.RedixMock

  alias ProductsManager.Services.Redis

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
  @source "redis_test"

  describe "get_by" do
    setup [:data_fixture]

    test "get_by/1 with valid id" do
      redix_mock_command(:ok, "GET", @valid_attrs)
      assert {:ok, @valid_attrs} = Redis.get_by(@source, @valid_attrs.id)
    end

    test "get_by/1 with invalid id", data do
      redix_mock_command(:error, "GET", nil)

      assert {:error, :not_found} = Redis.get_by(@source, "050505")
    end
  end

  describe "set" do
    test "set/1 with valid data" do
      redix_mock_command(:ok, "SET", @valid_attrs)
      assert :ok == Redis.set(@source, @valid_attrs)
    end

    test "set/1 with invalid data" do
      assert_raise KeyError, fn -> Redis.set(@source, @invalid_attrs) end
    end
  end

  describe "delete" do
    setup [:data_fixture]

    test "delete/1 with valid id" do
      redix_mock_command(:ok, "DEL", @valid_attrs.id)
      assert :ok == Redis.delete(@source, @valid_attrs.id)
    end

    test "delete/1 with invalid id" do
      redix_mock_command(:ok, "DEL", "01020305")
      assert :ok == Redis.delete(@source, "01020305")
    end

    test "delete_all/1" do
      redix_mock_command(:ok, "DEL", [])
      assert :ok == Redis.delete_all()
    end
  end

  defp data_fixture(_) do
    redix_mock_command(:ok, "SET", @valid_attrs)

    Redis.set(@source, @valid_attrs)
  end
end
