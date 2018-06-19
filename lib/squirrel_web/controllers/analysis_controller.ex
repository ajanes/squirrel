defmodule SquirrelWeb.AnalysisController do
  use SquirrelWeb, :controller

  alias Squirrel.Data

  action_fallback(SquirrelWeb.FallbackController)

  def read_analysis(conn, %{
        "topic" => topic,
        "subject" => subject,
        "predicate" => predicate,
        "source" => _source,
        "days" => days,
        "bars" => bars
      }) do
    predicate_as_integer = String.to_integer(predicate)
    days_as_integer = String.to_integer(days)
    bars_as_integer = String.to_integer(bars)

    analysis =
      Data.get_analysis(topic, subject, predicate_as_integer, days_as_integer, bars_as_integer)

    conn
    |> render("analysis.json", analysis: analysis)
  end
end
