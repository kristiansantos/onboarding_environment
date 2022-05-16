defmodule ProductsManagerWeb.Router do
  use ProductsManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ProductsManagerWeb do
    pipe_through :api

    resources "/products", ProductController, except: [:new, :edit]
    resources "/export", ExportController, except: [:new, :edit, :update, :delete, :show]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: ProductsManagerWeb.Telemetry
    end
  end
end
