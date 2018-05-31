defmodule Squirrel.Analyses do
  import Ecto.Query, warn: false
  alias Squirrel.Repo
  alias Squirrel.Analyses
  alias Squirrel.Analyses.Analysis
  alias Squirrel.Data.Fact

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

  def get_analyses(subject, predicate) do
    query =
      from(
        a in Analysis,
        where: a.subject == ^subject,
        where: a.predicate == ^predicate
      )

    Repo.all(query)
  end

  def get_analysis(subject, predicate) do
    query =
      from(
        a in Analysis,
        where: a.subject == ^subject,
        where: a.predicate == ^predicate,
        limit: 1
      )

    Repo.one(query)
  end

  def compute() do
    Repo.delete_all(from(a in Analysis))

    query =
      from(
        f in Fact,
        group_by: [f.subject, f.predicate],
        select: %{
          subject: f.subject,
          predicate: 1,
          object: %{count: count(f.id), granularity: 30}
        }
      )

    analyses = Repo.all(query)

    for analysis <- analyses do
      Analyses.create_analysis(analysis)
    end
  end
end
