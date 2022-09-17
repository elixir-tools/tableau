# Used by "mix format"
locals_without_parens = [
  layout: 1
]

[
  locals_without_parens: locals_without_parens,
  import_deps: [:plug],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [locals_without_parens: locals_without_parens]
]
