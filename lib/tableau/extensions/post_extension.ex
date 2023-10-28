defmodule Tableau.PostExtension.Config do
  @moduledoc """
  Configuration for PostExtension.

  ## Options
    - `:enabled` - boolean - Extension is active or not.
    - `:dir` - string - Directory to scan for markdown files. Defaults to `_posts`
    - `:future` - boolean - Show posts that have dates later than the current timestamp, or time at which the site is generated.
    - `:permalink` - string - Default output path for posts. Accepts `:title` as a replacement keyword, replaced with the post's provided title. If a post has a `:permalink` provided, that will override this value _for that post_.
    - `layout` - string - Elixir module providing page layout for posts. Default is nil
  """

  import Schematic

  defstruct enabled: true, dir: "_posts", future: false, permalink: nil, layout: nil

  def new(input), do: unify(schematic(), input)

  def schematic do
    schema(
      __MODULE__,
      %{
        optional(:enabled) => bool(),
        optional(:dir) => str(),
        optional(:future) => bool(),
        optional(:permalink) => str(),
        optional(:layout) => str()
      },
      convert: false
    )
  end
end

defmodule Tableau.PostExtension.Posts.Post do
  def build(filename, attrs, body) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    {:ok, post_config} =
      Tableau.PostExtension.Config.new(
        Map.new(Application.get_env(:tableau, Tableau.PostExtension, %{}))
      )

    attrs
    |> Map.put(:body, body)
    |> Map.put(:file, filename)
    |> Map.put(:layout, Module.concat([attrs.layout || post_config.layout]))
    |> Map.put(
      :date,
      DateTime.from_naive!(
        Code.eval_string(attrs.date) |> elem(0),
        config.timezone
      )
    )
    |> build_permalink(post_config)
  end

  def parse(_file_path, content) do
    Tableau.YamlFrontMatter.parse!(content, atoms: true)
  end

  defp build_permalink(%{permalink: permalink} = attrs, _config) do
    permalink
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp build_permalink(%{title: _title} = attrs, %{permalink: permalink})
       when not is_nil(permalink) do
    permalink
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp build_permalink(%{file: filename} = attrs, _) do
    filename
    |> Path.rootname()
    |> transform_permalink(attrs)
    |> then(&Map.put(attrs, :permalink, &1))
  end

  defp transform_permalink(path, attrs) do
    path
    |> String.replace(":title", attrs.title)
    |> String.replace(" ", "-")
    |> String.replace(~r/[^[:alnum:]\/\-]/, "")
    |> String.downcase()
  end
end

defmodule Tableau.PostExtension do
  @moduledoc """
  Markdown files (with YAML frontmatter) in the configured posts directory will be automatically compiled into Tableau pages.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and supports atom keys by prefixing a key with a colon `:title:`. Keys are all converted to atoms.

  * `:id` - An Elixir module to be used when compiling the backing `Tableau.Page`
  * `:title` - The title of the post
  * `:permalink` - The permalink of the post. `:title` will be replaced with the posts title and non alphanumeric characters removed. Optional.
  * `:date` - An Elixir `NaiveDateTime`, often presented as a `sigil_N`
  * `:layout` - A Tableau layout module.

  ## Example

  ```markdown
  ---
  id: "Update.Volume3"
  title: "The elixir-tools Update Vol. 3"
  permalink: "/news/:title"
  date: "~N[2023-09-19 01:00:00]"
  layout: "ElixirTools.PostLayout"
  ---
  ```

  ## URL generation

  If a `:permalink` is specified in the front matter, whatever is there _will_ be the post's permalink.

  If a global `:permalink` is set, it's rules will be used. See `Tableau.PostExtension.Config` for details.

  If permalink is set in either location, the file's name and path will be used

  In all cases, permalinks are stripped of non-alphanumeric characters.
  """

  {:ok, config} =
    Tableau.PostExtension.Config.new(
      Map.new(Application.compile_env(:tableau, Tableau.PostExtension, %{}))
    )

  @config config

  use Tableau.Extension, key: :posts, type: :pre_build, priority: 100

  def run(token) do
    :global.trans(
      {:create_posts_module, make_ref()},
      fn ->
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

        posts =
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

            post
          end

        {:ok, Map.put(token, :posts, posts)}
      end,
      [Node.self()],
      :infinity
    )
  end
end
