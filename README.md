# Scalar

Elixir library for generating scaled ranges for axis used in charts and graphs. The Scalar library along with Layout and Affine, take care of generating ranges and transforms needed for plotting data.

Take the following example where the y data for a chart has the following values:

    data = [0.0, 4.5, 2.3, 7.8, 1.0, 3.0, 6.3]

It's easy to determine a range for plotting the data when you can see the data or know the range but many times, the data might be unknown. Choosing an appropriate range make sure that the plotted data is shown in the best range possible.

For the data above, all information needed for plotting data using the Scaler module as follows:

    tick_list =
      Scalar.create(:data, data, 10, 20, [sync: true, stop: :major])
      |> Scalar.get_tick_list

Returns the following list of tuples:

    [
      {0, 0.0, 0, :major}, {1, 0.5, 0, :minor}, {2, 1.0, 0, :major},
      {3, 1.5, 0, :minor}, {4, 2.0, 0, :major}, {5, 2.5, 0, :minor},
      {6, 3.0, 0, :major}, {7, 3.5, 0, :minor}, {8, 4.0, 0, :major},
      {9, 4.5, 0, :minor}, {10, 5.0, 0, :major}, {11, 5.5, 0, :minor},
      {12, 6.0, 0, :major}, {13, 6.5, 0, :minor}, {14, 7.0, 0, :major},
      {15, 7.5, 0, :minor}, {16, 8.0, 0, :major}
    ]

Each tuple provides the following information:

  - tick number,
  - normalized tick value,
  - tick value 10^n factor,
  - tick type, either :minor or :major

These tuples are then used to drive the generation of the Y axis, the labels and the tick marks as well as the graph lines in the horizontal direction.

The same approach can be used for the X axis and grid lines.

## Git Update

Development Snapshot

Added :zero option that makes sure range will include zero.
Additional documentation done.

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
