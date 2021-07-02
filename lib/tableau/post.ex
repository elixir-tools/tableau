defmodule Tableau.Post do
  defstruct frontmatter: %{}, content: "", permalink: nil

  def build() do
    for file <- File.ls!("./_posts"), into: %{} do
      {:ok, matter, body} =
        file
        |> Path.absname("./_posts")
        |> YamlFrontMatter.parse_file()

      path =
        matter["permalink"]
        |> String.split("/")
        |> Enum.map(fn
          ":" <> slug ->
            matter[slug]

          x ->
            x
        end)

      permalink = Enum.join(path, "/")

      {permalink, struct!(__MODULE__, frontmatter: matter, content: body, permalink: permalink)}
    end
  end

  defimpl Tableau.Renderable do
    def render(%{frontmatter: frontmatter, permalink: permalink, content: content}) do
      post = Earmark.as_html!(content)

      layout = Module.concat(Tableau.module_prefix(), App)

      page =
        Phoenix.View.render_layout layout, :self, %{page: frontmatter} do
          Phoenix.HTML.raw(post)
        end
        |> Phoenix.HTML.safe_to_string()

      dir = "_site#{permalink}"

      File.mkdir_p!(dir)
      File.write!(dir <> "/index.html", page)
    end

    def layout?(_), do: false
  end
end
