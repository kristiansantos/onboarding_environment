json.array!(@products) do |product|
  json.extract! product, :id, :sku, :name, :description, :amount, :price
end
