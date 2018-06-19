defmodule SquirrelWeb.AnalysisView do
  use SquirrelWeb, :view
  alias SquirrelWeb.AnalysisView

  def render("index.json", %{analyses: analyses}) do
    %{data: render_many(analyses, AnalysisView, "analysis.json")}
  end

  def render("show.json", %{analysis: analysis}) do
    %{data: render_one(analysis, AnalysisView, "analysis.json")}
  end

  def render("analysis.json", %{analysis: analysis}) when not is_nil(analysis) do
    %{number_of_calls: analysis.number_of_calls, history: analysis.history}
  end

  def render("analysis.json", _) do
    %{number_of_calls: 0, history: []}
  end
end
