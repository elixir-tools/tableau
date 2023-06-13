defmodule Tableau.IndexHtml do
  @moduledoc false

  @behaviour Plug

  @doc ~S"""
  Initialize plug options

   - at: The request path to reach for static assets, defaults to "/"
   - default_file: Filename to serve when request path is a directory, defaults to "index.html"

  ## Example

      iex> Plug.Static.IndexHtml.init(at: "/doc")
      [matcher: ~r|^/doc/(.*/)?$|, default_file: "index.html"]
  """
  def init(opts), do: Keyword.merge([default_file: "index.html"], opts)

  @doc """
  Invokes the plug, adding default_file to request_path and path_info for directory paths

  ## Example

      iex> opts = Plug.Static.IndexHtml.init(at: "/doc")
      iex> conn = %Plug.Conn{request_path: "/doc/a/", path_info: ["doc", "a"]}
      iex> Plug.Static.IndexHtml.call(conn, opts) |> Map.take([:request_path, :path_info])
      %{path_info: ["doc", "a", "index.html"], request_path: "/doc/a/index.html"}
  """
  def call(conn, default_file: filename) do
    case Path.extname(conn.request_path) do
      "" ->
        %{
          conn
          | request_path: String.replace_suffix(conn.request_path, "/", "") <> "/#{filename}",
            path_info: conn.path_info ++ [filename]
        }

      _ ->
        conn
    end
  end
end
