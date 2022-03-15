defmodule ProductsManager.Repo do
  use Ecto.Repo,
    otp_app: :products_manager,
    adapter: Ecto.Adapters.Postgres
end
