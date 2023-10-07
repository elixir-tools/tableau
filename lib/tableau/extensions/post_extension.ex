defmodule Tableau.PostExtension.Config do
  import Schematic

  defstruct enabled: true, dir: "_posts", future: false

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:dir) => str(),
        optional(:future) => bool()
      },
      convert: false
    )
  end
end

defmodule Tableau.PostExtension.Posts.Post do
  {:ok, config} = Tableau.Config.new(Map.new(Application.compile_env(:tableau, :config, %{})))

  @config config

  def build(filename, attrs, body) do
    attrs
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:layout, Module.concat([attrs.layout]))
    |> Map.put(
      :date,
      DateTime.from_naive!(
        Code.eval_string(attrs.date) |> elem(0),
        @config.timezone
      )
    )
    |> Map.put(
      :permalink,
      attrs.permalink
      |> String.replace(":title", attrs.title)
      |> String.replace(" ", "-")
      |> String.replace(~r/[^[:alnum:]\/\-]/, "")
      |> String.downcase()
    )
  end

  def parse(_file_path, content) do
    Tableau.YamlFrontMatter.parse!(content, atoms: true)
  end
end

defmodule Tableau.PostExtension do
  @moduledoc """
  Markdown files (with YAML frontmatter) in the configured posts directory will be automatically compiled into Tableau pages.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and supports atom keys by prefixing a key with a colon `:title:`. Certain required keys must be presented as atoms, but all user provided keys may be string or atom keys.

  * `:id` - An Elixir module to be used when compiling the backing `Tableau.Page`
  * `:title` - The title of the post
  * `:permalink` - The permalink of the post. `:title` will be replaced with the posts title and non alphanumeric characters removed
  * `:date` - An Elixir `NaiveDateTime`, often presented as a `sigil_N`
  * `:layout` - A Tableau layout module.

  ## Example

  ```markdown
  ---
  :id: "Update.Volume3"
  :title: "The elixir-tools Update Vol. 3"
  :permalink: "/news/:title"
  :date: "~N[2023-09-19 01:00:00]"
  :layout: "ElixirTools.PostLayout"
  ---
  ```
  """
  {:ok, config} = Tableau.PostExtension.Config.new(Map.new(Application.compile_env(:tableau, :posts, %{})))

  @config config

  use Tableau.Extension, enabled: @config.enabled, type: :pre_build, priority: 100

  def run(_site) do
    Module.create(
      Tableau.PostExtension.Posts,
      quote do
        use NimblePublisher,
          build: __MODULE__.Post,
          from: "#{unquote(@config.dir)}/*.md",
          as: :posts,
          highlighters: [:makeup_elixir],
          parser: Tableau.PostExtension.Posts.Post

        def posts(_opts \\ []) do
          @posts
          |> Enum.sort_by(& &1.date, {:desc, DateTime})
          |> then(fn posts ->
            if unquote(@config.future) do
              posts
            else
              Enum.reject(posts, &(DateTime.compare(&1.date, DateTime.utc_now()) == :gt))
            end
          end)
        end
      end,
      Macro.Env.location(__ENV__)
    )

    for post <- apply(Tableau.PostExtension.Posts, :posts, []) do
      {:module, _module, _binary, _term} =
        Module.create(
          Module.concat([post.id]),
          quote do
            @external_resource unquote(post.file)
            use Tableau.Page, unquote(Macro.escape(Keyword.new(post)))

            def template(_assigns) do
              unquote(post.body)
            end
          end,
          Macro.Env.location(__ENV__)
        )
    end

    :ok
  end
end
