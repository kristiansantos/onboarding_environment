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
config :tirexs, lib: TirexsHttpBehaviourMock
config :redix, lib: RedixBehaviourMock
config :task_bunny, lib: TaskBunnyBehaviourMock

config :task_bunny, disable_auto_start: true
