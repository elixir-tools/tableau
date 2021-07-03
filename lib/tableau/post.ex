defmodule Tableau.Post do
  alias Tableau.Render

  defstruct frontmatter: %{}, content: "", layout: Tableau.Layout.default(), permalink: nil

  def build() do
    for file <- File.ls!("./_posts"), into: %{} do
      {:ok, matter, body} =
        file
        |> Path.absname("./_posts")
        |> YamlFrontMatter.parse_file()

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

      {permalink,
       struct!(__MODULE__,
         frontmatter: matter,
         layout: layout,
         content: body,
         permalink: permalink
       )}
    end
  end

  defimpl Tableau.Renderable do
    def render(post) do
      %{frontmatter: frontmatter, permalink: permalink, content: content, layout: layout} = post
      post = Earmark.as_html!(content)

      page =
        layout
        |> Render.gather_modules([post])
        |> Render.recursively_render(page: frontmatter)
        |> Phoenix.HTML.safe_to_string()

      dir = "_site#{permalink}"

      File.mkdir_p!(dir)
      File.write!(dir <> "/index.html", page)
    end

    def layout?(_), do: false
  end
end
