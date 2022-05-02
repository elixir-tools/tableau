# Tableau

Experimental static site generator using [Temple](https://github.com/mhanberg/temple).

## Goals

- [x] Uses Temple's component model
- [x] Good code and browser reloading on file change
- [x] Easy to use the current Node.js JS/CSS tooling
- [ ] Handles stuff like RSS, sitemap, SEO.
- [ ] Ability to work with "data" (either dynamic data or static files)
- [ ] Good project generation experience.

## Installation

1. Clone this repo.
1. `mix new my_site`
1. Add `{:tableau, path: "path/to/tableau"}` to your `mix.exs`

## Getting Started

### Pages

Pages are Tableau.Pages, which is a form of Temple.Component that's located in the `./lib/pages` directory, and that have the module suffix `Pages.PageName`. So if you were to have an `/about` page, it would be generated from the `YourApp.Pages.About` module that implements a Temple component.

These pages are rendered withing Layout modules, which are also Temple Components

#### Layout

```elixir
defmodule TabDemo.Layouts.App do
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
            div class: "border-4 border-green-500" do
              a class: "text-blue-500 hover:underline", href: "/about" do
                "About"
              end

              a class: "text-blue-500 hover:underline", href: "/posts" do
                "Posts"
              end

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

#### Page

```elixir
defmodule TabDemo.Pages.About do
  use Tableau.Page

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

The root `/` can be built by create an "Index" module, `YourApp.Pages.Index`.

You can change which layout your page renders within by using the `layout` macro.

```elixir
defmodule TabDemo.Layouts.Sidebar do
  use Tableau.Layout
  
  import Temple

  layout TabDemo.Layouts.App

  def render(assigns) do
    temple do
      aside do
        ul do
          li do: "Home"
          li do: "Profile"
          li do: "Messages"
        end
      end

      slot :default
    end
  end
end

defmodule TabDemo.Pages.Home do
  use Tableau.Page

  import Temple

  layout TabDemo.Layouts.Sidebar

  def render(assigns) do
    temple do
      div do
        c TheFeed
      end
    end
  end
end
```


### Posts

Posts are markdown files with YAML frontmatter that are located in the `_posts` directory. 

The following post would be rendered to the path `/posts/hello-word!`.

```markdown
---
layout: "TabDemo.Layouts.Sidebar"
title: "hello world!"
category: "elixir"
permalink: /posts/:category/:title
---

# Yo!

This is a post
```

Pages included a `@posts` assign that includes all posts and their frontmatter data. You can use this to render an archive of posts.

```elixir
defmodule TabDemo.Pages.Posts do
  use Tableau.Page

  import Temple

  def render(assigns) do
    temple do
      ul class: "list-disc pl-6" do
        for post <- @posts do
          li do
            a class: "text-blue-500 hover:underline", href: post.permalink do
              post.frontmatter["title"]
            end
          end
        end
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
    ~r"_posts/.*.md",
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

### Development

The dev server can be started with `mix tableau.server`. On file change, a browser reload will be triggered and the page your requesting will be re-built during the request.
