# Scalar

Elixir library for generating scaled ranges for axis used in charts and graphs. The Scalar library along with Layout and Affine, take care of generating ranges and transforms needed for plotting data.

Take the following example where the y data for a chart has the following values:

    data = [4.5, 2.3, 7.8, 1.0, 3.0, 6.3]

It's easy to determine a range for plotting the data when you can see the data or know the range but many times, the data might be unknown. Choosing an appropriate range make sure that the plotted data is shown in the best range possible.

For the data above, all information needed for plotting data using the Scaler module as follows:

    tick_list =
      Scalar.create(data, 10, 20)
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
  - tick value,
  - scale factor,
  - tick type, either :minor or :major

These tuples are then used to drive the generation of the Y axis, the labels and the tick marks as well as the graph lines in the horizontal direction.

The same approach can be used for the X axis and grid lines.

Also, a different factor set can be provided as an option to the create. The
following is example data for feet above sea level in a lake level chart.

  [579.54, 581.47]
    |> Scalar.create(10, 30, [factors: [12, 6, 4, 3, 2, 1]])
    |> Scalar.get_tick_list

This will produce a tick list that has the minor ticks at 12 per foot and the
major ticks every 3 inches.

## Git Update

Development Snapshot

Added documentation and tests for a different factor set.
Much cleanup still required.

## Development List

  - Might add options for start of tick list being :major or :minor and the
    same for the end of the tick list. List would pad out to the selected
    tick type. Currently, it can be either.
  - Test for sync'd and non-sync'd tick lists.
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
