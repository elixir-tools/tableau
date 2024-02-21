[
  import_deps: [<%= if @template == :temple do %>:temple,<% end %>],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
