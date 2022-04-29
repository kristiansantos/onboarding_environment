defmodule ProductsManager.ProductTest do
  use ProductsManager.DataCase

  alias ProductsManager.Models.Product

  describe "changeset/1" do
    test "when all params are valid, returns a valid changeset" do
      valid_attrs = %{
        amount: 42,
        description: "some description",
        name: "name_test",
        price: 120.5,
        sku: "ABC-DEFG-HJK",
        barcode: "A124BR66"
      }

      changeset = Product.changeset(%Product{}, valid_attrs)

      assert changeset.valid? == true
    end

    test "when there are invalid name param, returns an invalid changeset" do
      invalid_attrs = %{
        amount: 42,
        description: "some description",
        name: nil,
        price: 120.5,
        sku: "ABC-DEFG-HJK",
        barcode: "A124BR66"
      }

      changeset = Product.changeset(%Product{}, invalid_attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "when there are invalid price param, returns an invalid changeset" do
      invalid_attrs = %{
        amount: 42,
        description: "some description",
        name: "name_test",
        price: 0,
        sku: "ABC-DEFG-HJK",
        barcode: "A124BR66"
      }

      changeset = Product.changeset(%Product{}, invalid_attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{price: ["must be greater than 0"]}
    end

    test "when there are invalid sku param, returns an invalid changeset" do
      invalid_attrs = %{
        amount: 42,
        description: "some description",
        name: "name_test",
        price: 120.5,
        sku: "invalid! sku!",
        barcode: "A124BR66"
      }

      changeset = Product.changeset(%Product{}, invalid_attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{sku: ["has invalid format"]}
    end

    test "when there are invalid barcode param, returns an invalid changeset" do
      invalid_attrs = %{
        amount: 42,
        description: "some description",
        name: "name_test",
        price: 120.5,
        sku: "ABC-DEFG-HJK",
        barcode: "INVBAR"
      }

      changeset = Product.changeset(%Product{}, invalid_attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{barcode: ["should be at least 8 character(s)"]}
    end
  end
end
