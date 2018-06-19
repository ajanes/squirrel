defmodule SquirrelWeb.PageController do
  use SquirrelWeb, :controller

  action_fallback(SquirrelWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
