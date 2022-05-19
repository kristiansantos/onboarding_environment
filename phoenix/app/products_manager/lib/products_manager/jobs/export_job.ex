defmodule ProductsManager.Jobs.ExportJob do
  use TaskBunny.Job

  require Logger

  alias ProductsManager.Contexts.Manager
  alias ProductsManager.Services.ExportService

  def perform(%{"filters" => filters}) do
    products = Manager.list_products(filters)

    ExportService.to_csv(products)
  end
end
