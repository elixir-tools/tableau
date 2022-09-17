defmodule Tableau.DataTest do
  use ExUnit.Case, async: true

  alias Tableau.Provider
  alias Tableau.Data.{Yaml, Json, Toml}

  @data %{
    "books" => [
      %{"name" => "Jurassic Park", "author" => "Michael Crichton"},
      %{"name" => "Lord of the Rings", "author" => "JRR Tolkien"},
      %{"name" => "Dark Matter", "author" => "Blake Crouch"}
    ]
  }

  describe "data/0" do
    test "fetches the data" do
      bypass = Bypass.open(port: 9000)

      Bypass.expect(bypass, "GET", "/books", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@data))
      end)

      # we compile this during the test so that we can use Bypass
      assert [{mod, _}] = Code.compile_file("test/fixtures/data.ex")

      assert %{
               books1: %Yaml{data: @data},
               books2: %Json{data: @data},
               books3: %Toml{data: @data},
               books4: %Tableau.Support.MyData.Http{data: @data}
             } = mod.data()
    end
  end

  describe "Tableau.Provider.fetch/1" do
    test "can fetch based on an implementation" do
      yaml = %Yaml{file: fixture(:books)}

      %Yaml{data: data} = Provider.fetch(yaml)

      assert @data == data
    end
  end

  defp fixture(name) do
    "test/support/fixtures/#{name}.yml"
  end
end
