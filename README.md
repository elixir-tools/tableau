# Tableau

[![Discord](https://img.shields.io/badge/Discord-5865F3?style=flat&logo=discord&logoColor=white&link=https://discord.gg/nNDMwTJ8)](https://discord.gg/6XdGnxVA2A)
[![Hex.pm](https://img.shields.io/hexpm/v/tableau)](https://hex.pm/packages/tableau)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/tableau/)
[![GitHub Discussions](https://img.shields.io/github/discussions/elixir-tools/tableau)](https://github.com/elixir-tools/tableau/discussions)

Static Site Generator for Elixir.

## Goals

- [x] Good code and browser reloading on file change
- [x] Easy to use the current Node.js JS/CSS tooling
- [x] Extensions
- [x] Ability to work with "data" (either dynamic data or static files)
    - [x] YAML Files
    - [x] Elixir scripts (.exs files)
- [ ] Handles stuff like Posts, RSS, sitemap, SEO.
    - [x] Posts
    - [x] RSS
    - [x] Sitemap
    - [ ] SEO
- [x] Project generator

## Installation

The easiest way to get started is to generate a new project using the `tableau.new` mix task.

Currently the generator can create a website using several different template syntaxes and assets frameworks.

- Templates
  - [HEEx](https://github.com/phoenixframework/phoenix)
  - [Temple](https://github.com/mhanberg/temple)
  - EEx
- Assets
  - [TailwindCSS](https://tailwindcss.com)
  - Vanilla (Just a regular CSS file)

Please run `mix help tableau.new` or `mix tableau.new --help` to see all of the possible flags.

```
mix archive.install hex tableau_new

mix tableau.new my_awesome_site
```

Otherwise, you can just install Tableau into a new mix project.

```elixir
def deps do
  [
    {:tableau, "~> 0.14"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/tableau>.

## Built with Tableau

| Site                                                       | Template                                                                        | Styling    | Source                                                                              |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------- |
| [www.elixir-tools.dev](https://www.elixir-tools.dev)       | [Temple](https://github.com/mhanberg/temple)                                    | Tailwind   | [elixir-tools/elixir-tools.dev](https://github.com/elixir-tools/elixir-tools.dev)   |
| [www.mitchellhanberg.com](https://www.mitchellhanberg.com) | [Liquid](https://github.com/edgurgel/solid)                                     | Tailwind   | [mhanberg/blog](https://github.com/mhanberg/blog)                                   |
| [pdx.su](https://pdx.su)                                   | [Temple](https://github.com/mhanberg/temple)                                    | CSS        | [paradox460/pdx.su](https://github.com/paradox460/pdx.su)                           |
| [Xmeyers](https://andyl.github.io/xmeyers)                 | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2)   | Tailwind   | [andyl/xmeyers](https://github.com/andyl/xmeyers)                                   |
| [0x7f](https://0x7f.dev)                                   | [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2)   | magick.css | [0x7fdev/site](https://github.com/0x7fdev/site)                                     |

## Getting Started

The examples in the README use the [Temple](https://github.com/mhanberg/temple) library to demonstrate that Tableau can be used with any markup language of your choice. You could easily use the builtin EEx, or use HEEx, Surface, or HAML.

### Layouts

Layouts are modules that use the `use Tableau.Layout` macro.

Layouts have access to the `@site` and `@page` assign.

The `@site` assign contains your site's config.

The `@page` assign contains all the options passed to the `use Tableau.Page` macro.

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

          title do
            @page.some_assign
          end

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
          c &Tableau.live_reload/1
        end
      end
    end
  end
end
```

#### Page

Pages are modules that use the `use Tableau.Page` macro.

Required options:

* `:layout` - which layout module to use.
* `:permalink` - the permalink of the page

Any remaining options are arbitrary and will be available under the `@page` assign available to layout and page templates.

```elixir
defmodule MySite.AboutPage do
  use Tableau.Page,
    layout: MySite.RootLayout,
    permalink: "/about",
    some_assign: "foo"

  import Temple

  def template(assigns) do
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

All you need to do is render the `Tableau.live_reload/1` component right after your `body` tag.

```elixir
# lib/layouts/app.ex

defmodule YourApp.Layouts.App do
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
            render(@inner_content)
          end
        end

        if Mix.env() == :dev do
          c &Tableau.live_reload/1
        end
      end
    end
  end
end
```


### JS/CSS

You can arbitrarily start other build tools as "watchers". This is inspired by the way Phoenix does it.

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

This will start a long running process that will independently build your CSS as it sees files change.

These are started automatically when you run `mix tableau.server`.

### Static Assets

Other static assets can be copied into the "out" directory by placing them in an `extra` directory in the root of your project.

This directory can be configured.

```elixir
config :tableau, :config,
  include_dir: "static"
```

### Development

The dev server can be started with `mix tableau.server`. On file change, a browser reload will be triggered and the page your requesting will be re-built during the request.
