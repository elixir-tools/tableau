defmodule Tableau.Data.Json do
  @moduledoc """
  The JSON data provider.
  """

  defstruct [:data, :file]

  defimpl Tableau.Provider do
    alias Tableau.Data.Json

    def fetch(%Json{file: file} = json) do
      data = file |> File.read!() |> Jason.decode!()

      %{json | data: data}
    end
  end
end

defmodule Tableau.Data.Yaml do
  @moduledoc """
  The YAML data provider.
  """

  defstruct [:data, :file]

  defimpl Tableau.Provider do
    alias Tableau.Data.Yaml

    def fetch(%Yaml{file: file} = yaml) do
      data = YamlElixir.read_from_file!(file)

      %{yaml | data: data}
    end
  end
end

defmodule Tableau.Data.Toml do
  @moduledoc """
  The TOML data provider.
  """

  defstruct [:data, :file]

  defimpl Tableau.Provider do
    alias Tableau.Data

    def fetch(%Data.Toml{file: file} = toml) do
      data = Toml.decode_file!(file)

      %{toml | data: data}
    end
  end
end

defmodule Tableau.Data do
  @moduledoc """
  Tableau sites can utilize static data provided in files (JSON, YAML, TOML) or from a custom data source..

  To configure a data source, create a module in your project and use the `Tableau.Data` module. Your project's module can be called whatever you'd like.

  The second argument to the using macro is a keyword list of your sources. The keys are the (arbitrary) names of the sources and the value is either a string to a file or the struct of a custom data source.

  ```elixir
  defmodule MySite.Data do
    use Tableau.Data,
      projects: "path/to/projects.json",
      another: "path/to/file.yml",
      one_more: "path/to/file.toml",
      books: %MySite.Goodreads{}
  end
  ```

  This will load your files into a `MySite.Data.data/0` function that you can use in your website.

  ## Custom Data Source

  Your custom data source should be a struct that implements the `Tableau.Provider` protocol.

  All keys in the struct are arbitrary and can be whatever you'd like.

  Let's implement the example that implements a custom data source for https://goodreads.com.

  This example shows that we can fetch arbitrary data using an HTTP client and compile it into our `data/0` function.

  This example uses the [Req](https://github.com/wojtekmach/req) and [EasyXML](https://github.com/wojtekmach/easyxml) libraries.

  ```elixir
  defmodule MySite.MyOwnStruct do
    defstruct [:data]

    defimpl Tableau.Provider do
      def fetch(my_own_struct) do
        Application.ensure_all_started(:req)

        response =
          Req.get!(
            "https://www.goodreads.com/review/list.xml",
            params: [
              v: 2,
              id: System.get_env("GOODREADS_ID"),
              shelf: "read",
              key: System.get_env("GOODREADS_KEY"),
              per_page: 200
            ]
          ).body
          |> EasyXML.parse!()

        data =
          for review <- EasyXML.xpath(response, "//review") do
            book = EasyXML.xpath(review, "//book") |> List.first()

            %{
              id: book["id"],
              title: book["title_without_series"],
              asin: book["asin"],
              image: book["image_url"],
              author: List.first(EasyXML.xpath(book, "//author"))["name"],
              date_read: review["read_at"]
            }
          end

        %{goodreads | data: data}
      end
    end
  end
  ```
  """
  defmacro __using__(opts) do
    data =
      for {name, path_or_struct} <- opts, into: %{} do
        data =
          cond do
            match?({:%, _, _}, path_or_struct) ->
              {struct, _} = Code.eval_quoted(path_or_struct)
              struct

            is_binary(path_or_struct) ->
              path = path_or_struct
              extension = Path.extname(path)

              case extension do
                ".yml" -> %Tableau.Data.Yaml{file: path}
                ".json" -> %Tableau.Data.Json{file: path}
                ".toml" -> %Tableau.Data.Toml{file: path}
              end

            true ->
              raise "There is no provider for that data source!"
          end

        {name, Tableau.Provider.fetch(data)}
      end
      |> Macro.escape()

    quote do
      for %{file: file} <- unquote(data) do
        Module.put_attribute(__MODULE__, :external_resource, file)
      end

      def data do
        unquote(data)
      end
    end
  end
end
