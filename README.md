# Tableau

Experimental static site generator using [Temple](https://github.com/mhanberg/temple).

## Goals

- Uses Temple's component model
- Good code and browser reloading on file change.
- Easy to use the current Node.js JS/CSS tooling
- Handles stuff like RSS, sitemap, SEO.

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

  render do
    "<!DOCTYPE html>"

    html lang: "en" do
      head do
        meta(charset: "utf-8")
        meta(http_equiv: "X-UA-Compatible", content: "IE=edge")
        meta(name: "viewport", content: "width=device-width, initial-scale=1.0")

        script src: "https://unpkg.com/tailwindcss-jit-cdn"
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
    end
  end
end
```

#### Page

```elixir
defmodule TabDemo.Pages.About do
  use Tableau.Page

  render do
    span class: "text-red-500 font-bold" do
      "i'm a super cool and smart!"
    end
  end
end
```

The root `/` can be built by create an "Index" module, `YourApp.Pages.Index`.

You can change which layout your page renders within by using the `layout` macro.

```elixir
defmodule TabDemo.Layouts.Sidebar do
  use Tableau.Layout

  layout TabDemo.Layouts.App

  render do
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

defmodule TabDemo.Pages.Home do
  use Tableau.Page

  layout TabDemo.Layouts.Sidebar

  render do
    div do
      c TheFeed
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

  render do
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
```

### Development

The dev server can be started with `mix tableau.server`. On file change, a browser reload will be triggered and the page your requesting will be re-built during the request.
