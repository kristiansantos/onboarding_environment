defmodule ProductsManagerWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import ProductsManagerWeb.ChannelCase

      @endpoint ProductsManagerWeb.Endpoint
    end
  end

  setup do
    :ok
  end
end
