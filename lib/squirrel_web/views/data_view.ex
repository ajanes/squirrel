defmodule SquirrelWeb.DataView do
  use SquirrelWeb, :view
  alias SquirrelWeb.DataView

  def render("show.json", %{facts: facts}) do
    %{data: render_many(facts, DataView, "fact.json", as: :fact)}
  end

  def render("fact.json", %{fact: fact}) do
    %{
      subject: fact.subject,
      predicate: fact.predicate,
      object:
        if Map.has_key?(fact, :object) do
          fact.object
        else
          nil
        end,
      source: fact.source,
      topic: fact.topic,
      expires_at: fact.expires_at,
      received_at: fact.received_at
    }
  end

  def render("statistics.json", %{statistics: statistics}) do
    %{
      number_of_facts: statistics.number_of_facts
    }
  end
end
