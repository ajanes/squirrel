# Squirrel

Squirrel is a web server to collect and distribute data. It provides four methods:

  * /api/write: stores a call of a method
  * /api/read: retrieves all data present in the system
  * /api/read_one: retrieves the number of records collected for a given method
  * /api/compute: invokes an analysis, in this initial version it just aggregates the collected data counting it per method

## How to run squirrel

  * Install http://www.phoenixframework.org/
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
