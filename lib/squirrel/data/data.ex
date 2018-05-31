defmodule Squirrel.Data do
  import Ecto.Query, warn: false
  alias Squirrel.Repo
  alias Squirrel.Data.Fact

  def create_fact(attrs \\ %{}) do
    %Fact{}
    |> Fact.changeset(attrs)
    |> Repo.insert()
  end

  def update_fact(%Fact{} = fact, attrs) do
    fact
    |> Fact.changeset(attrs)
    |> Repo.update()
  end

  def get_facts(subject, predicate) do
    query =
      from(
        f in Fact,
        where: f.subject == ^subject,
        where: f.predicate == ^predicate
      )

    Repo.all(query)
  end
end
