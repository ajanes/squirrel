defmodule SquirrelWeb.DataController do
  use SquirrelWeb, :controller

  alias Squirrel.Data

  # This method expects data in form of a json document with the following contents:
  # [
  #   {
  #     subject: "The thing I want to talk about"
  #     predicate: "What I want to say about it"
  #     object: "The fact I want to report about it (might be null)"
  #   }
  # ]

  def write(conn, %{"data" => facts}) do
    for fact <- facts do
      Data.create_fact(fact)
    end

    conn
    |> send_resp(200, "")
  end

  def read(conn, %{"subject" => subject, "predicate" => predicate}) do
    fact = Data.get_facts(subject, predicate)

    conn
    |> render("fact.json", fact: fact)
  end
end
