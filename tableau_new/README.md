# mix tableau.new

Mix task to generate a new [Tableau](https://github.com/elixir-tools/tableau) website.

## Installation

```elixir
mix archive.install hex tableau_new
```

## --help

```
mix tableau.new <app_name> [<opts>]

Flags

--template Template syntax to use. Options are heex, temple, eex. (required)
--assets   Asset framework to use. Options are vanilla, tailwind. (optional, defaults to vanilla)
--help     Shows this help text.


Example

mix tableau.new my_awesome_site
mix tableau.new my_awesome_site --template temple
mix tableau.new my_awesome_site --template eex --assets tailwind
```
