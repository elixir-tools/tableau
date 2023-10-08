defmodule Tableau.DataExtensionTest do
  use ExUnit.Case, async: true

  alias Tableau.DataExtension

  test "reads/evals files from disk" do
    token = %{data: %{dir: "test/support/fixtures"}}

    assert {:ok, actual} = DataExtension.run(token)

    assert actual == %{
             data: %{
               "foobar" => %{
                 foo: ["bar"]
               },
               "books" => %{
                 "books" => [
                   %{"author" => "Michael Crichton", "name" => "Jurassic Park"},
                   %{"author" => "JRR Tolkien", "name" => "Lord of the Rings"},
                   %{"author" => "Blake Crouch", "name" => "Dark Matter"}
                 ]
               },
               "movies" => %{
                 "movies" => [
                   %{"name" => "Back to the Future"},
                   %{"name" => "Spider-Man 2"},
                   %{"name" => "Titanic"}
                 ]
               }
             }
           }
  end
end
