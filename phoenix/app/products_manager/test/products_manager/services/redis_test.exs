defmodule ProductsManager.RedisTest do
  use ProductsManager.DataCase

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

    test "get_by/1 with valid id", data do
      assert {:ok, @valid_attrs} = Redis.get_by(@valid_attrs.id, @source)
    end

    test "get_by/1 with invalid id", data do
      assert {:error, :not_found} = Redis.get_by("050505", @source)
    end
  end

  describe "set" do
    test "set/1 with valid data" do
      assert :ok = Redis.set(@valid_attrs, @source)
    end

    test "set/1 with invalid data" do
      assert_raise KeyError, fn -> Redis.set(@invalid_attrs, @source) end
    end
  end

  describe "delete" do
    setup [:data_fixture]

    test "delete/1 with valid id" do
      assert 1 = Redis.delete(@valid_attrs.id, @source)
    end

    test "delete/1 with invalid id" do
      assert 0 = Redis.delete("01020305", @source)
    end

    test "delete_all/1" do
      assert :ok = Redis.delete_all()
    end
  end

  defp data_fixture(_) do
    Redis.set(@valid_attrs, @source)
  end
end
