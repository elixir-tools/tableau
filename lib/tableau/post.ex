defmodule Tableau.Post do
  alias Tableau.Render

  defstruct frontmatter: %{},
            content: "",
            layout: Tableau.Layout.default(),
            permalink: nil,
            path: nil

  def build(path, callback \\ fn x -> x end) do
    for file <- File.ls!(path) do
      path =
        file
        |> Path.absname(path)
        |> Path.expand()

      __MODULE__
      |> struct!(path: path)
      |> Tableau.Renderable.refresh()
      |> callback.()
    end
  end

  defimpl Tableau.Renderable do
    def render(post, _ \\ []) do
      %{permalink: permalink, layout: layout, content: content, frontmatter: frontmatter} = post

      html = Earmark.as_html!(content)

      page =
        layout
        |> Render.gather_modules([html])
        |> Render.recursively_render(page: frontmatter)
        |> Phoenix.HTML.safe_to_string()

      dir = "_site#{permalink}"

      File.mkdir_p!(dir)
      File.write!(dir <> "/index.html", page)

      post
    end

    def refresh(%{path: path} = post) do
      {:ok, matter, body} = YamlFrontMatter.parse_file(path)

      layout =
        if layout = matter["layout"] do
          Module.concat([layout])
        else
          Tableau.Layout.default()
        end

      permalink =
        matter["permalink"]
        |> String.split("/")
        |> Enum.map(fn
          ":" <> slug ->
            matter[slug]

          x ->
            x
        end)
        |> Enum.join("/")
        |> String.replace(" ", "-")

      struct!(post,
        frontmatter: matter,
        layout: layout,
        content: body,
        permalink: permalink,
        path: path
      )
    end

    def layout?(_), do: false
  end
end
