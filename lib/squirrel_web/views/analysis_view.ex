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
    %{result: analysis.object}
  end

  def render("analysis.json", _) do
    %{result: nil}
  end
end
