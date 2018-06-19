# Squirrel

Squirrel is a web server to collect and distribute data. It provides two methods:

  * /api/write: stores data
  * /api/read: reads data

## How to run squirrel

  * Install http://www.phoenixframework.org/
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
