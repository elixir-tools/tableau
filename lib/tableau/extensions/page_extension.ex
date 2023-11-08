defmodule Tableau.PageExtension do
  @moduledoc """
  Markdown files (with YAML frontmatter) in the configured pages directory will be automatically compiled into Tableau pages.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and all keys are converted to atoms.

  * `:title` - The title of the page
  * `:permalink` - The permalink of the page.
  * `:layout` - A string representation of a Tableau layout module.

  ## Example

  ```yaml
  id: "GettingStarted"
  title: "Getting Started"
  permalink: "/docs/:title"
  layout: "ElixirTools.PageLayout"
  ```

  ## Permalink

  The permalink is a string with colon prefixed template variables.

  These variables will be swapped with the corresponding YAML Frontmatter key, with the result being piped through `to_string/1`.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:dir` - string - Directory to scan for markdown files. Defaults to `_pages`
  - `:permalink` - string - Default output path for pages. Accepts `:title` as a replacement keyword, replaced with the page's provided title. If a page has a `:permalink` provided, that will override this value _for that page_.
  - `:layout` - string - Elixir module providing page layout for pages. Default is nil.

  ### Example

  ```elixir
  config :tableau, Tableau.PageExtension,
    enabled: true,
    dir: "_docs",
    permalink: "/docs/:title",
    layout: "MyApp.PageLayout"
  ```
  """

  use Tableau.Extension, key: :pages, type: :pre_build, priority: 100

  {:ok, config} =
    Tableau.PageExtension.Config.new(Map.new(Application.compile_env(:tableau, Tableau.PageExtension, %{})))

  @config config

  def run(token) do
    :global.trans(
      {:create_pages_module, make_ref()},
      fn ->
        Module.create(
          Tableau.PageExtension.Pages,
          quote do
            use NimblePublisher,
              build: __MODULE__.Page,
              from: "#{unquote(@config.dir)}/**/*.md",
              as: :pages,
              parser: Tableau.PageExtension.Pages.Page,
              html_converter: Tableau.PageExtension.Pages.HTMLConverter

            def pages(_opts \\ []) do
              @pages
            end
          end,
          Macro.Env.location(__ENV__)
        )

        for {mod, _, _} <- :code.all_available(),
            mod = Module.concat([to_string(mod)]),
            Tableau.Graph.Node.type(mod) == :page,
            mod.__tableau_opts__()[:__tableau_page_extension__] do
          :code.purge(mod)
          :code.delete(mod)
        end

        pages =
          for page <- apply(Tableau.PageExtension.Pages, :pages, []) do
            {:module, _module, _binary, _term} =
              Module.create(
                :"#{System.unique_integer()}",
                quote do
                  use Tableau.Page, unquote(Macro.escape(Keyword.new(page)))

                  @external_resource unquote(page.file)
                  def template(_assigns) do
                    unquote(page.body)
                  end
                end,
                Macro.Env.location(__ENV__)
              )

            page
          end

        {:ok, Map.put(token, :pages, pages)}
      end,
      [Node.self()],
      :infinity
    )
  end
end
