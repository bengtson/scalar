# Scalar

Elixir library for generating scaled ranges for axis used in charts and graphs.

## Git Update

Development Snapshot

Scalar working for zero-based ranges with sync and stop options.

## Development List

  - Get the trim list working for non-synced minor major tick lists.
  - Modify the code to handle a non-zero based range.
  - Modify the code to handle a zero crossed range.
  - Modify the code to handle a negative zero pinned range.
  - Update the documentation.
  - Add the ExDocs

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `scalar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:scalar, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/scalar](https://hexdocs.pm/scalar).
