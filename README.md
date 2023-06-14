# Tableau

Static Site Generator for Elixir.

## Goals

- [x] Good code and browser reloading on file change
- [x] Easy to use the current Node.js JS/CSS tooling
- [ ] Ability to work with "data" (either dynamic data or static files)
- [ ] Handles stuff like RSS, sitemap, SEO.

## Installation

This package can be installed by adding `tableau` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tableau, "~> 0.1"}
  ]
end
```
Documentation can be found at <https://hexdocs.pm/tableau>.

## Getting Started

The examples in the README use the [Temple](https://github.com/mhanberg/temple) library to demonstrate that Tableau can be used with any markup language of your choice. You could easily use the builtin EEx, or use HEEx, Surface, or HAML.

```elixir
defmodule MySite.RootLayout do
  use Tableau.Layout

  import Temple

  def template(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
        head do
          meta charset: "utf-8"
          meta http_equiv: "X-UA-Compatible", content: "IE=edge"
          meta name: "viewport", content: "width=device-width, initial-scale=1.0"

          link rel: "stylesheet", href: "/css/site.css"
        end

        body class: "font-sans" do
          main class: "container mx-auto px-2" do
            div class: "border-4 border-green-500" do
              a class: "text-blue-500 hover:underline", href: "/about" do
                "About"
              end

              a class: "text-blue-500 hover:underline", href: "/posts" do
                "Posts"
              end

              render @inner_content
            end
          end
        end

        if Mix.env() == :dev do
          c &Tableau.Components.live_reload/1
        end
      end
    end
  end
end
```

#### Page

```elixir
defmodule MySite.AboutPage do
  use Tableau.Page,
    layout: MySite.RootLayout,
    permalink: "/about"

  import Temple

  def render(assigns) do
    temple do
      span class: "text-red-500 font-bold" do
        "i'm a super cool and smart!"
      end
    end
  end
end
```

### Live Reloading

You can specify a set of directories/files to watch for changes, and the browser will automatically refresh.

```elixir
# config/config.exs
import Config

config :tableau, :reloader,
  patterns: [
    ~r"lib/layouts/.*.ex",
    ~r"lib/pages/.*.ex",
    ~r"lib/components.ex",
    ~r"_site/.*.css"
  ]
```

All you need to do is render the `Tableau.Components.LiveReload` component right after your `body` tag.

```elixir
# lib/layouts/app.ex

defmodule YourApp.Layouts.App do
  use Tableau.Layout

  import Temple

  def render(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
        head do
          meta charset: "utf-8"
          meta http_equiv: "X-UA-Compatible", content: "IE=edge"
          meta name: "viewport", content: "width=device-width, initial-scale=1.0"

          link rel: "stylesheet", href: "/css/site.css"
        end

        body class: "font-sans" do
          main class: "container mx-auto px-2" do
              slot :default
            end
          end
        end

        if Mix.env() == :dev do
          c &Tableau.Components.live_reload/1
        end
      end
    end
  end
end
```


### JS/CSS

You can arbitrarily start other build tools as "watchers". This is inspired by the way [Phoenix does it](TODO).

```elixir
# config/config.exs

import Config

config :tableau, :assets,
  npx: [
    "tailwindcss",
    "-o",
    "_site/css/site.css",
    "--watch"
  ]

# or if you are using a package similar to the TailwindCSS hex package

config :tableau, :assets, tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}

import_config "#{config_env()}.exs"
```

This will start a long running process that will independently build your CSS as it see's files change.

These are started automatically when you run `mix tableau.server`.

### Static Assets

Other static assets can be copied into the "out" directory by placing them in an `extra` directory in the root of your project.

This directory can be configured.

```elixir
config :tableau, :include, "static"
```

### Development

The dev server can be started with `mix tableau.server`. On file change, a browser reload will be triggered and the page your requesting will be re-built during the request.
