defmodule ProductsManagerWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import ProductsManagerWeb.ConnCase

      alias ProductsManagerWeb.Router.Helpers, as: Routes

      @endpoint ProductsManagerWeb.Endpoint
    end
  end

  setup do
    Mongo.Ecto.truncate(ProductsManager.Repo)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
