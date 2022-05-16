use Mix.Config

config :products_manager, ProductsManagerWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"

# Services
config :elasticsearch, service: ProductsManager.Services.ElasticsearchService
config :elasticsearch, :index, "/products_manager"

config :redis, service: ProductsManager.Services.RedisService
