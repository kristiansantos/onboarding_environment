defmodule ProductsManager.ProductTest do
  use ProductsManager.DataCase

  alias ProductsManager.Models.Product

  @valid_attrs %{
    amount: 42,
    description: "some description",
    name: "some name",
    price: 120.0,
    sku: "ABC-DEFG-HJK",
    barcode: "A124BR66"
  }
  @invalid_attrs %{amount: nil, description: nil, name: nil, price: nil, sku: nil}

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

    test "when there are invalid params, returns an invalid changeset" do
      response = Product.changeset(%Product{}, @invalid_attrs)

      assert %Ecto.Changeset{
               action: nil,
               changes: %{},
               errors: [name: {"can't be blank", [validation: :required]}],
               data: %ProductsManager.Models.Product{},
               valid?: false
             } = response

      assert errors_on(response) == %{name: ["can't be blank"]}
    end
  end
end
