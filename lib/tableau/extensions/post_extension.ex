defmodule Tableau.PostExtension do
  @moduledoc """
  Markdown files (with YAML frontmatter) in the configured posts directory will be automatically compiled into Tableau pages.

  Certain frontmatter keys are required and all keys are passed as options to the `Tableau.Page`.

  ## Options

  Frontmatter is compiled with `yaml_elixir` and all keys are converted to atoms.

  * `:title` - The title of the post. Falls back to the first `<h1>` tag if present in the body.
  * `:permalink` - The permalink of the post. `:title` will be replaced with the posts title and non alphanumeric characters removed. Optional.
  * `:date` - A string representation of an Elixir `NaiveDateTime`, often presented as a `sigil_N`. This will be converted to your configured timezone.
  * `:layout` - A string representation of a Tableau layout module.

  ## Example

  ```yaml
  id: "Update.Volume3"
  title: "The elixir-tools Update Vol. 3"
  permalink: "/news/:title"
  date: "~N[2023-09-19 01:00:00]"
  layout: "ElixirTools.PostLayout"
  ```

  ## Permalink

  The permalink is a string with colon prefixed template variables.

  These variables will be swapped with the corresponding YAML Frontmatter key, with the result being piped through `to_string/1`.

  In addition, there are `:year`, `:month`, and `:day` template variables.

  ## Configuration

  - `:enabled` - boolean - Extension is active or not.
  - `:dir` - string - Directory to scan for markdown files. Defaults to `_posts`
  - `:future` - boolean - Show posts that have dates later than the current timestamp, or time at which the site is generated.
  - `:permalink` - string - Default output path for posts. Accepts `:title` as a replacement keyword, replaced with the post's provided title. If a post has a `:permalink` provided, that will override this value _for that post_.
  - `:layout` - string - Elixir module providing page layout for posts. Default is nil

  ### Example

  ```elixir
  config :tableau, Tableau.PostExtension,
    enabled: true,
    dir: "_articles",
    future: true,
    permalink: "/articles/:year/:month/:day/:title",
    layout: "MyApp.PostLayout"
  ```
  """

  use Tableau.Extension, key: :posts, type: :pre_build, priority: 100

  def run(token) do
    token = put_in(token.posts, Tableau.PostExtension.Posts.posts())
    {:ok, token}
  end
end
