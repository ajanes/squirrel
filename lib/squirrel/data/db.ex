defmodule Squirrel.Data.Db do
  import Ecto.Query, warn: false

  alias Squirrel.Repo
  alias Squirrel.Data.Fact
  alias Squirrel.Data.Analysis

  def create_fact(attrs \\ %{}) do
    %Fact{}
    |> Fact.changeset(attrs)
    |> Repo.insert()
  end

  def get_facts() do
    today = NaiveDateTime.utc_now()

    query =
      from(
        f in Fact,
        where: f.expires_at > ^today,
        order_by: f.inserted_at
      )

    Repo.all(query)
  end

  def create_analysis(attrs \\ %{}) do
    %Analysis{}
    |> Analysis.changeset(attrs)
    |> Repo.insert()
  end

  def update_analysis(%Analysis{} = analysis, attrs) do
    analysis
    |> Analysis.changeset(attrs)
    |> Repo.update()
  end
end
