json.array!(@products) do |product|
  json.extract! product, :id, :sku, :name, :description, :amount, :price
  json.url product_url(product, format: :json)
end
