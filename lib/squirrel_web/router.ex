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

    put("/write", DataController, :add_facts)
    get("/read", AnalysisController, :read_analysis)

    get("/show", DataController, :show_facts)
    get("/statistics", DataController, :show_statistics)

    get("/persist", DataController, :persist)
    get("/reload", DataController, :reload)

    get("/clear", DataController, :clear)
  end
end
