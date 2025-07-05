defmodule Tableau.YamlFrontMatterTest do
  use ExUnit.Case, async: true

  alias Tableau.YamlFrontMatter

  test "parsers front matter with body" do
    content = """
    ---
    foo: bar
    ---

    let's go
    """

    assert {%{foo: "bar"}, "\nlet's go\n"} == YamlFrontMatter.parse!(content)
  end

  test "parsers front matter without body" do
    content =
      String.trim("""
      ---
      foo: bar
      ---
      """)

    assert {%{foo: "bar"}, ""} == YamlFrontMatter.parse!(content)
  end
end
