# Sup

Concurrent viewer counter using dynamic supervisors and genservers
## Installation

Export the env below to increase erlang total concurrent processes

export ELIXIR_ERL_OPTIONS="+P 10000000"

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sup` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sup, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sup](https://hexdocs.pm/sup).

