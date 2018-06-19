defmodule SquirrelWeb.AnalysisControllerTest do
  use SquirrelWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "Check if upload and analysis 1 works", %{conn: conn} do
    assert get(conn, data_path(conn, :clear)).status == 200

    received_at_1 = NaiveDateTime.utc_now() |> NaiveDateTime.to_iso8601()

    received_at_2 =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * 86400)
      |> NaiveDateTime.to_iso8601()

    received_at_3 =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-2 * 86400)
      |> NaiveDateTime.to_iso8601()

    received_at_4 =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-3 * 86400)
      |> NaiveDateTime.to_iso8601()

    subject = "0d4a03f7-bf42-4cc8-aed8-d8749ebfb385"
    predicate = 1
    source = "c7f38fd1-eded-4bfc-a170-2dc162c27d97"
    topic = "3bb7b105-690d-4791-9b34-175c4a6a943c"

    expires_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(30)
      |> NaiveDateTime.to_iso8601()

    data_1 = %{
      received_at: received_at_1,
      subject: subject,
      predicate: predicate,
      source: source,
      topic: topic,
      expires_at: expires_at
    }

    for _n <- 1..4 do
      put(conn, data_path(conn, :add_facts, fact: data_1))
    end

    conn_2 =
      get(
        conn,
        analysis_path(
          conn,
          :read_analysis,
          subject: subject,
          predicate: predicate,
          source: "7340780d-ee34-41f1-84b7-a6e37f6ba9ba",
          days: 10,
          bars: 0,
          topic: topic
        )
      )

    %{resp_body: resp_body} = conn_2
    assert resp_body == "{\"number_of_calls\":4,\"history\":[]}"

    data_2 = %{
      received_at: received_at_2,
      subject: subject,
      predicate: predicate,
      source: source,
      topic: topic
    }

    for _n <- 1..3 do
      put(conn, data_path(conn, :add_facts, fact: data_2))
    end

    data_3 = %{
      received_at: received_at_3,
      subject: subject,
      predicate: predicate,
      source: source,
      topic: topic,
      expires_at: expires_at
    }

    for _n <- 1..2 do
      put(conn, data_path(conn, :add_facts, fact: data_3))
    end

    data_4 = %{
      received_at: received_at_4,
      subject: subject,
      predicate: predicate,
      source: source,
      topic: topic,
      expires_at: expires_at
    }

    for _n <- 1..1 do
      put(conn, data_path(conn, :add_facts, fact: data_4))
    end

    conn_3 =
      get(
        conn,
        data_path(
          conn,
          :show_facts,
          topic: topic
        )
      )

    assert conn_3.status == 200

    conn_4 =
      get(
        conn,
        analysis_path(
          conn,
          :read_analysis,
          subject: subject,
          predicate: predicate,
          source: "7340780d-ee34-41f1-84b7-a6e37f6ba9ba",
          days: 3,
          bars: 0,
          topic: topic
        )
      )

    %{resp_body: resp_body} = conn_4
    assert resp_body == "{\"number_of_calls\":9,\"history\":[]}"

    conn_5 =
      get(
        conn,
        analysis_path(
          conn,
          :read_analysis,
          subject: subject,
          predicate: predicate,
          source: "7340780d-ee34-41f1-84b7-a6e37f6ba9ba",
          days: 3,
          bars: 3,
          topic: topic
        )
      )

    %{resp_body: resp_body} = conn_5
    assert resp_body == "{\"number_of_calls\":9,\"history\":[50,75,100]}"

    assert get(conn, data_path(conn, :clear)).status == 200

    conn_6 =
      get(
        conn,
        analysis_path(
          conn,
          :read_analysis,
          subject: "TtpWeb.AdminArchiveController.index(conn%2C%20_params)",
          predicate: 1,
          source: "3f79485f-0722-46c3-9d26-e728ffae80ae&",
          days: 30,
          bars: 15,
          topic: topic
        )
      )

    %{resp_body: resp_body} = conn_6
    assert resp_body == "{\"number_of_calls\":0,\"history\":[]}"
  end

  test "Check if expiry_at is set after received_at", %{conn: conn} do
    assert get(conn, data_path(conn, :clear)).status == 200

    received_at_1 = NaiveDateTime.utc_now()
    subject = "0d4a03f7-bf42-4cc8-aed8-d8749ebfb385"
    predicate = 1
    source = "c7f38fd1-eded-4bfc-a170-2dc162c27d97"
    topic = "3bb7b105-690d-4791-9b34-175c4a6a943c"

    data_1 = %{
      received_at: NaiveDateTime.to_iso8601(received_at_1),
      subject: subject,
      predicate: predicate,
      source: source,
      topic: topic
    }

    put(conn, data_path(conn, :add_facts, fact: data_1))

    conn_1 =
      get(
        conn,
        data_path(
          conn,
          :show_facts,
          topic: topic
        )
      )

    assert conn_1.status == 200

    assert :gt ==
             conn_1.resp_body
             |> Poison.decode!()
             |> Map.get("data")
             |> Enum.at(0)
             |> Map.get("expires_at")
             |> NaiveDateTime.from_iso8601!()
             |> NaiveDateTime.compare(received_at_1)
  end
end
