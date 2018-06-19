defmodule Squirrel.Data do
  use GenServer

  alias Squirrel.Data.Stash

  def start_link(args) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, args, name: :data)
  end

  def get_facts(topic, limit) do
    GenServer.call(:data, {:get_all_facts, topic, limit})
  end

  def get_facts(topic, subject, days) do
    GenServer.call(:data, {:get_some_facts, topic, subject, days})
  end

  def add_fact(fact) do
    GenServer.cast(:data, {:add_fact, fact})
  end

  def remove_expired_facts() do
    GenServer.cast(:data, {:remove_expired_facts})
  end

  def persist() do
    GenServer.cast(:data, {:persist})
  end

  def reload() do
    GenServer.cast(:data, {:reload})
  end

  def clear() do
    GenServer.cast(:data, {:clear})
  end

  def get_analysis(topic, subject, predicate, days, bars)
      when is_number(predicate) and is_number(days) and is_number(bars) and days >= bars do
    interesting_facts = get_facts(topic, subject, days)

    number_of_calls =
      interesting_facts
      |> Enum.count()

    if bars > 0 do
      {:ok, midnight} = Time.new(0, 0, 0)
      {:ok, almost_midnight} = Time.new(23, 59, 59)

      history =
        1..bars
        |> Enum.map(fn n ->
          {:ok, from} =
            Date.add(Date.utc_today(), -(n - 1))
            |> NaiveDateTime.new(midnight)

          {:ok, to} =
            Date.add(Date.utc_today(), -(n - 1))
            |> NaiveDateTime.new(almost_midnight)

          interesting_facts
          |> Enum.filter(fn x ->
            NaiveDateTime.compare(x.received_at, from) == :gt and
              NaiveDateTime.compare(x.received_at, to) == :lt
          end)
          |> Enum.count()
        end)

      max = Enum.max(history)

      history =
        if max > 0 do
          history
          |> Enum.map(fn x ->
            trunc(100 * x / max)
          end)
          |> Enum.reverse()
        else
          []
        end

      %{number_of_calls: number_of_calls, history: history}
    else
      %{number_of_calls: number_of_calls, history: []}
    end
  end

  def get_analysis(_topic, _subject, _predicate, _days, _bars) do
    nil
  end

  def get_statistics(topic) do
    GenServer.call(:data, {:get_statistics, topic})
  end

  @impl true
  def init(_args) do
    {:ok, %{facts: :not_loaded_yet}}
  end

  @impl true
  def handle_call({:get_some_facts, topic, subject, days}, _from, %{facts: facts} = state)
      when facts != :not_loaded_yet do
    days_back =
      Date.utc_today()
      |> Date.add(-days)

    today = NaiveDateTime.utc_now()

    interesting_facts =
      facts
      |> Enum.filter(fn x ->
        x.subject == subject and x.topic == topic and
          Date.compare(NaiveDateTime.to_date(x.received_at), days_back) == :gt and
          NaiveDateTime.compare(x.expires_at, today) == :gt
      end)

    {:reply, interesting_facts, state}
  end

  @impl true
  def handle_call({:get_all_facts, topic, limit}, _from, %{facts: facts} = state)
      when facts != :not_loaded_yet do
    interesting_facts =
      facts
      |> Enum.filter(fn x ->
        x.topic == topic
      end)
      |> Enum.take(limit)

    {:reply, interesting_facts, state}
  end

  @impl true
  def handle_call({:get_statistics, topic}, _from, %{facts: facts} = state)
      when facts != :not_loaded_yet do
    number_of_facts =
      facts
      |> Enum.filter(fn x ->
        x.topic == topic
      end)
      |> Enum.count()

    {:reply, %{number_of_facts: number_of_facts}, state}
  end

  @impl true
  def handle_call(args, from, _facts) do
    facts = Stash.get_facts()
    handle_call(args, from, %{facts: facts})
  end

  @impl true
  def handle_cast({:add_fact, fact}, %{facts: facts}) when facts != :not_loaded_yet do
    fact = Map.put(fact, :is_persisted, false)
    facts = facts ++ [fact]
    {:noreply, %{facts: facts}}
  end

  @impl true
  def handle_cast({:remove_expired_facts}, %{facts: facts}) when facts != :not_loaded_yet do
    today = NaiveDateTime.utc_now()

    facts =
      facts
      |> Enum.filter(fn x -> NaiveDateTime.compare(x.expires_at, today) == :gt end)

    {:noreply, %{facts: facts}}
  end

  @impl true
  def handle_cast({:persist}, %{facts: facts}) when facts != :not_loaded_yet do
    facts = Stash.persist_facts(facts)
    {:noreply, %{facts: facts}}
  end

  @impl true
  def handle_cast({:reload}, %{facts: facts}) do
    Stash.persist_facts(facts)
    facts = Stash.get_facts()

    {:noreply, %{facts: facts}}
  end

  @impl true
  def handle_cast({:clear}, _state) do
    {:noreply, %{facts: []}}
  end

  @impl true
  def handle_cast(args, _state) do
    facts = Stash.get_facts()
    handle_cast(args, %{facts: facts})
  end

  @impl true
  def terminate(_reason, %{facts: facts}) when facts != :not_loaded_yet do
    Stash.persist_facts(facts)
  end

  @impl true
  def terminate(_reason, %{facts: :not_loaded_yet}) do
  end

  def child_spec() do
    %{
      id: :data,
      start: {Squirrel.Data, :start_link, []}
    }
  end
end
