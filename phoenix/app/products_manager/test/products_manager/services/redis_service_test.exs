defmodule ProductsManager.RedisServiceTest do
  use ProductsManager.DataCase
  use ProductsManager.RedixMock

  alias ProductsManager.Services.RedisService

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
  @invalid_attrs %{
    amount: nil,
    description: nil,
    name: nil,
    price: nil,
    sku: nil,
    created_at: nil,
    updated_at: nil
  }
  @source "redis_test"

  setup :verify_on_exit!

  describe "get_by/2" do
    test "With valid id" do
      redix_mock_command(:ok, "GET", @valid_attrs)
      assert {:ok, @valid_attrs} == RedisService.get_by(@source, @valid_attrs.id)
    end

    test "With invalid id" do
      redix_mock_command(:error, "GET", nil)

      assert {:error, :not_found} == RedisService.get_by(@source, "050505")
    end
  end

  describe "set/2" do
    test "With valid data" do
      redix_mock_command(:ok, "SET", @valid_attrs)
      assert :ok == RedisService.set(@source, @valid_attrs)
    end

    test "With invalid data" do
      assert_raise KeyError, fn -> RedisService.set(@source, @invalid_attrs) end
    end
  end

  describe "set_expire/3" do
    test "With valid data" do
      redix_mock_command(:ok, "SET", @valid_attrs)
      assert :ok == RedisService.set_expire(@source, @valid_attrs, 60)
    end

    test "With invalid data" do
      assert_raise KeyError, fn -> RedisService.set_expire(@source, @invalid_attrs, 60) end
    end
  end

  describe "delete/2" do
    test "With valid id" do
      redix_mock_command(:ok, "DEL", @valid_attrs.id)
      assert :ok == RedisService.delete(@source, @valid_attrs.id)
    end

    test "With invalid id" do
      redix_mock_command(:ok, "DEL", "01020305")
      assert :ok == RedisService.delete(@source, "01020305")
    end
  end

  describe "delete_all/1" do
    test "With sucess delete all document data" do
      redix_mock_command(:ok, "DEL", [])
      assert :ok == RedisService.delete_all()
    end
  end

end
