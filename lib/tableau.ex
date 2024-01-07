defmodule Tableau do
  @moduledoc """
  ## Global Site Configuration

  * `:include_dir` - string - Directory that is just copied to the output directory. Defaults to `extra`.
  * `:timezone` - string - Timezone to use when parsing date times. Defaults to `Etc/UTC`.
  * `:base_path - string - base path to use with Github Pages or web-servers that use a location prefix for Vhosts
  * `:url` - string (required) - The URL of your website.
  * `:markdown` - keyword
      * `:mdex` - keyword - Options to pass to `MDEx.to_html/2`

  ## Working with Github Pages or web-server Vhosts

  Github Pages provides a root url like `https://andyl.github.io/xmeyers`, where
  the `xmeyers` prefix is a virtual host identifier tied to the repo at
  `https://github.com/andyl/xmeyers`.

  With Nginx and Apache it is common to use a location prefix for Vhosts.
  Here is an example NGINX config snippet:

  ```
  server {
    listen 80;
    server_name myhost.com;

    location /site1 {
        # Configuration for site1 - eg the root directive to a directory
        # root /var/www/site1;
    }

    location /site2 {
        # Configuration for site2
        # Similar configuration as site1, adjusted for site2 specifics
    }

    # Other configuration...
  }
  ```

  To make Tableau's development server (`mix tableau.server`) also use a Vost
  prefix, configure your app with the `:base_path` attribute.  With that, your
  website HREFs will work in both development and production.

  ## Example

  In `config/config.exs`:

  ```elixir
  config :tableau, :config,
    url: "http://localhost:4999",
    base_path: "xmeyers",
    markdown: [
      ...
    ]
  ```

  In `root_layout.ex`:

  ```elixir
  def template(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <title>Xmeyers</title>
        <link rel="icon" href="/xmeyers/static/img/favicon.ico" type="image/x-icon" />
        <link rel="stylesheet" type="text/css" href="/xmeyers/css/site.css" />
     ...
  ```
  """

  @doc """
  Component to connect to the development server via websocket to broadcast that the page should reload.

  By default, connects to `'ws://' + location.host + '/ws'`.

  See `WebDevUtils` for configuration options.
  """
  defdelegate live_reload(assigns), to: WebDevUtils.Components

  @doc """
  Convert markdown content to HTML using `MDEx.to_html/2`.

  Will use the globally configured options, but you can also pass it overrides.
  """
  def markdown(content, overrides \\ []) do
    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    MDEx.to_html(content, Keyword.merge(config.markdown[:mdex], overrides))
  end
end
