defmodule ProductsManager.Models.Product do
  use Ecto.Schema
  use QueryBuilder
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "products" do
    field :amount, :integer
    field :description, :string
    field :name, :string
    field :price, :float
    field :sku, :string
    field :barcode, :string

    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku, :name, :description, :amount, :price, :barcode])
    |> validate_required([:name])
    |> validate_format(:sku, ~r/^([a-zA-Z0-9]|-)+$/)
    |> validate_number(:price, greater_than: 0)
    |> validate_length(:barcode, min: 8, max: 13)
  end
end
