defmodule ProductsManager.ProductTest do
  use ProductsManager.DataCase

  alias ProductsManager.Models.Product

  @valid_attrs %{
    amount: 42,
    description: "some description",
    name: "name_test",
    price: 120.5,
    sku: "ABC-DEFG-HJK",
    barcode: "A124BR66"
  }

  describe "changeset/1" do
    test "when all params are valid, returns a valid changeset" do
      response = Product.changeset(%Product{}, @valid_attrs)

      assert %Ecto.Changeset{
               action: nil,
               changes: @valid_attrs,
               errors: [],
               data: %ProductsManager.Models.Product{},
               valid?: true
             } = response
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

      response = Product.changeset(%Product{}, invalid_attrs)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{},
               errors: [name: {"can't be blank", [validation: :required]}],
               data: %ProductsManager.Models.Product{},
               valid?: false
             } = response

      assert errors_on(response) == %{name: ["can't be blank"]}
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

      response = Product.changeset(%Product{}, invalid_attrs)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{
                 amount: 42,
                 barcode: "A124BR66",
                 description: "some description",
                 name: "name_test",
                 price: 0.0,
                 sku: "ABC-DEFG-HJK"
               },
               errors: [
                 price:
                   {"must be greater than %{number}",
                    [validation: :number, kind: :greater_than, number: 0]}
               ],
               data: %ProductsManager.Models.Product{},
               valid?: false
             } = response

      assert errors_on(response) == %{price: ["must be greater than 0"]}
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

      response = Product.changeset(%Product{}, invalid_attrs)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{
                 amount: 42,
                 barcode: "A124BR66",
                 description: "some description",
                 name: "name_test",
                 price: 120.5,
                 sku: "invalid! sku!"
               },
               errors: [sku: {"has invalid format", [validation: :format]}],
               data: %ProductsManager.Models.Product{},
               valid?: false
             } = response

      assert errors_on(response) == %{sku: ["has invalid format"]}
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

      response = Product.changeset(%Product{}, invalid_attrs)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{
                 amount: 42,
                 barcode: "INVBAR",
                 description: "some description",
                 name: "name_test",
                 price: 120.5,
                 sku: "ABC-DEFG-HJK"
               },
               errors: [
                 barcode:
                   {"should be at least %{count} character(s)",
                    [count: 8, validation: :length, kind: :min, type: :string]}
               ],
               data: %ProductsManager.Models.Product{},
               valid?: false
             } = response

      assert errors_on(response) == %{barcode: ["should be at least 8 character(s)"]}
    end
  end
end
