defmodule Tableau do
  @moduledoc """
  Documentation for `Tableau`.
  """

  @site_dir "_site"

  def compile_file(path) do
    Code.put_compiler_option(:ignore_module_conflict, true)
    [{mod, _}] = Code.compile_file(path)
    Code.put_compiler_option(:ignore_module_conflict, false)

    mod
  end

  def compile_all do
    Mix.Task.rerun("compile", [])
    Mix.Task.rerun("compile.elixir", [])
  end

  def build(mod, data) do
    File.mkdir_p!(@site_dir)
    mod_parts = Module.split(mod)
    route = mod_parts |> List.last() |> String.downcase()

    page =
      Phoenix.View.render_layout Module.concat(module_prefix(), App), :self, data do
        Phoenix.View.render(mod, :self, data)
      end
      |> Phoenix.HTML.safe_to_string()

    if route == "index" do
      File.write!("#{@site_dir}/index.html", page)
    else
      dir = "#{@site_dir}/#{route}"

      File.mkdir_p!(dir)
      File.write!(dir <> "/index.html", page)
    end
  end

  def build_post(data) do
    post = Earmark.as_html!(data.content)

    page =
      Phoenix.View.render_layout Module.concat(module_prefix(), App), :self, %{} do
        Phoenix.HTML.raw(post)
      end
      |> Phoenix.HTML.safe_to_string()

    dir = "#{@site_dir}/#{data.permalink}"

    File.mkdir_p!(dir)
    File.write!(dir <> "/index.html", page)
  end

  def module_prefix() do
    Mix.Project.config()
    |> Keyword.fetch!(:app)
    |> to_string()
    |> Macro.camelize()
    |> List.wrap()
    |> Module.concat()
  end
end
