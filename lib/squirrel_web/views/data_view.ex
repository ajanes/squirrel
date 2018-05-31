defmodule SquirrelWeb.DataView do
  use SquirrelWeb, :view

  def render("fact.json", %{fact: fact}) do
    %{
      result: fact.object
    }
  end
end
