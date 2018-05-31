defmodule SquirrelWeb.Router do
  use SquirrelWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug :protect_from_forgery
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SquirrelWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api", SquirrelWeb do
    pipe_through(:api)

    put("/write", DataController, :write)
    get("/read", AnalysisController, :read)
    get("/read_one", AnalysisController, :read_one)
    get("/compute", AnalysisController, :compute)
  end
end
