defmodule SquirrelWeb.DataController do
  use SquirrelWeb, :controller

  alias Squirrel.Data

  action_fallback(SquirrelWeb.FallbackController)

  # This method expects data in form of a json document with the following contents:
  # [
  #   {
  #     subject: "The thing I want to talk about"
  #     predicate: "What I want to say about it"
  #     object: "The fact I want to report about it (might be null)"
  #   }
  # ]

  def add_facts(conn, %{"fact" => fact}) do
    add_fact(fact)

    conn
    |> send_resp(200, "")
  end

  def add_facts(conn, %{"facts" => facts}) do
    for fact <- facts, do: add_fact(fact)

    conn
    |> send_resp(200, "")
  end

  defp add_fact(fact) do
    fact = for {key, val} <- fact, into: %{}, do: {String.to_atom(key), val}

    fact =
      if Map.has_key?(fact, :received_at) do
        %{received_at: received_at} = fact
        received_at = NaiveDateTime.from_iso8601!(received_at)

        Map.put(fact, :received_at, received_at)
      else
        received_at = NaiveDateTime.utc_now()
        Map.put(fact, :received_at, received_at)
      end

    if Map.has_key?(fact, :expires_at) do
      %{expires_at: expires_at} = fact
      expires_at = NaiveDateTime.from_iso8601!(expires_at)
      Map.put(fact, :expires_at, expires_at)

      Data.add_fact(fact)
    else
      expiry_period = Application.get_env(:squirrel, :default_expiry_period_in_days)
      today = NaiveDateTime.add(NaiveDateTime.utc_now(), expiry_period * 60 * 60 * 24)
      fact_with_expires_at = Map.put(fact, :expires_at, today)

      Data.add_fact(fact_with_expires_at)
    end
  end

  def show_facts(conn, %{"topic" => topic, "limit" => limit}) do
    facts = Data.get_facts(topic, limit)

    conn
    |> render("show.json", facts: facts)
  end

  def show_facts(conn, %{"topic" => topic}) do
    facts = Data.get_facts(topic, -10)

    conn
    |> render("show.json", facts: facts)
  end

  def persist(conn, _params) do
    Squirrel.Data.persist()

    conn
    |> send_resp(200, "")
  end

  def reload(conn, _params) do
    Squirrel.Data.reload()

    conn
    |> send_resp(200, "")
  end

  def clear(conn, _params) do
    Squirrel.Data.clear()

    conn
    |> send_resp(200, "")
  end

  def show_statistics(conn, %{"topic" => topic}) do
    statistics = Data.get_statistics(topic)

    conn
    |> render("statistics.json", statistics: statistics)
  end
end
