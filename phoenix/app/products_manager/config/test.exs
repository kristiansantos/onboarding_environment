use Mix.Config

config :products_manager, ProductsManager.Repo,
  database: "products_manager_test",
  hostname: "localhost"

config :products_manager, ProductsManagerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn

config :tirexs, :uri, "http://127.0.0.1:9200"

config :elasticsearch, :index, "/products_manager_test"

# Hammox mocks
config :elasticsearch, :service, ElasticsearchBehaviourMock
config :redis, :service, RedisBehaviourMock

config :exredis,
  host: "127.0.0.1",
  port: 6379,
  password: "",
  db: 0,
  reconnect: :no_reconnect,
  max_queue: :infinity
