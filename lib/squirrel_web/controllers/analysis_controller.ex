defmodule SquirrelWeb.AnalysisController do
  use SquirrelWeb, :controller

  alias Squirrel.Analyses

  def compute(conn, _params) do
    Analyses.compute()

    conn
    |> send_resp(200, "")
  end

  def read(conn, %{"subject" => subject, "predicate" => predicate}) do
    predicate_as_integer = String.to_integer(predicate)
    analyses = Analyses.get_analyses(subject, predicate_as_integer)

    conn
    |> render("index.json", analyses: analyses)
  end

  def read_one(conn, %{"subject" => subject, "predicate" => predicate}) do
    predicate_as_integer = String.to_integer(predicate)
    analysis = Analyses.get_analysis(subject, predicate_as_integer)

    conn
    |> render("analysis.json", analysis: analysis)
  end
end
