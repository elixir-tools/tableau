defmodule Tableau.Converter do
  @moduledoc """
  Defines the interface for the converter module used by extensions to parse markup files.
  """

  @doc """
  Converts content into HTML.

  Is given the file path, the content of the files (sans front matter), the front matter, and a list of options.
  """
  @callback convert(filepath :: String.t(), front_matter :: map(), content :: String.t(), opts :: Keyword.t()) ::
              String.t()
end
