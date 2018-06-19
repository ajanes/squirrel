defmodule Squirrel.Data.Stash do
  use GenServer

  alias Squirrel.Data.Db
  alias Squirrel.Repo

  def start_link(args) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, args, name: :stash)
  end

  def persist_facts(facts) do
    GenServer.call(:stash, {:persist_facts, facts})
  end

  def get_facts() do
    GenServer.call(:stash, :get_facts)
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:get_facts, _from, state) do
    facts =
      Db.get_facts()
      |> Enum.map(fn fact -> Map.from_struct(fact) end)
      |> Enum.map(fn fact -> Map.put(fact, :is_persisted, true) end)
      |> Enum.map(fn fact -> Map.delete(fact, :__meta__) end)

    {:reply, facts, state}
  end

  @impl true
  def handle_call({:persist_facts, facts}, _from, state) do
    not_yet_persisted_facts = Enum.filter(facts, fn x -> x.is_persisted == false end)

    Repo.transaction(fn ->
      for fact <- not_yet_persisted_facts do
        Db.create_fact(fact)
      end
    end)

    today = NaiveDateTime.utc_now()

    facts =
      facts
      |> Enum.map(fn fact -> Map.put(fact, :is_persisted, true) end)
      |> Enum.filter(fn x -> NaiveDateTime.compare(x.expires_at, today) == :gt end)

    {:reply, facts, state}
  end

  def child_spec() do
    %{
      id: :stash,
      start: {Squirrel.Data.Stash, :start_link, []}
    }
  end
end
