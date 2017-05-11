defmodule Scalar do
  @moduledoc """
  This is a scaler that can be used to determine the scaling for charts and
  graphs. When provided with a dataset and defined objectives, it will
  generate the necessary information for creating axis.
  """

  defstruct [
    factors: [20, 10, 5, 4, 2, 1],
    data: nil,
    data_minimum: nil,
    data_maximum: nil,
    major_allowed: nil,
    minor_allowed: nil,
    range: nil,
    normalized_range: nil,
    scale: nil,
    magnitude: nil,
    log: nil,
    minor_target: nil,
    major_target: nil,
    minor_factor: nil,
    major_factor: nil,
    tick_start_value: nil,
    tick_count: nil,
    sync: true,
    tick_list: nil
  ]

  @doc """
  Creates a scaler that can be used to generate appropriately scaled intervals
  for axis on a chart. Data must be a list of the data values that will be
  plotted, though it only uses the min and max. Instead of the actual data,
  you may provide [min, max] instead. `major_ticks` and `minor_ticks` are the
  maximum that can be used in the scaler.

  Options are:

    :sync - set to true insures that minor tick marks are syncronized to every
    major tick mark. When false, ticks may or may not be syncrhonized. For instance, minor at 0.02 intervals will mill a major at 0.5 but hit it at 0.0 and 1.0.

    :end - This an option for determining when the tick mark list should end.
    The :minor option will continue the list until the first minor tick after the max data value.
    The :major option will continue until the first major tick after the max data value.

  See the documentation for create/3. The `fun` argument should be provided
  if the data list has  more than single data points. The function must take
  one of the data elements and return the single data value.
  """

  def create data, major_allowed, minor_allowed, opts \\ [] do
    %Scalar{}
    |> struct(opts)
    |> struct(data: data)
    |> struct(major_allowed: major_allowed, minor_allowed: minor_allowed)
    |> calc_key_parameters
    |> layout_ticks
    |> sync_ticks_option
    |> finalize_values
    |> gen_tick_list
  end

  def get_tick_list scalar do
    scalar.tick_list
  end

  defp calc_key_parameters scalar do
    {min, max} = scalar.data |> Enum.min_max
    range = max - min
    log = :math.log10 range
    magnitude = trunc(log)
    scale = :math.pow(10,magnitude)
    normalized_range = :math.pow(10,log-magnitude)
    minor_target = normalized_range / scalar.minor_allowed
    major_target = normalized_range / scalar.major_allowed

    struct(scalar,
      data_minimum: min,
      data_maximum: max,
      range: range,
      log: log,
      magnitude: magnitude,
      normalized_range: normalized_range,
      scale: scale,
      minor_target: minor_target,
      major_target: major_target
    )
  end

  defp layout_ticks scalar do


    # Find the best tick values based on the factor table. This will be the
    # most ticks without exceeding the specified maximum ticks allowed.
    minor_factor =
      scalar.factors
      |> Enum.find(&(layout_fits?(scalar, &1, scalar.minor_target, scalar.minor_allowed)))

    major_factor =
      scalar.factors
      |> Enum.find(&(layout_fits?(scalar, &1, scalar.major_target, scalar.major_allowed)))


    # Place in structure.
    struct(scalar,
      minor_factor: minor_factor,
      major_factor: major_factor,
    )
  end


  # Makes sure that 1.0/factor is >= target and that the min, max range
  # also fits into the tick range.
  defp layout_fits? scalar, factor, target, allowed do
    tick_value = 1.0/factor
    factor_check = tick_value >= target

    div_min = Float.floor(scalar.data_minimum / (tick_value * scalar.scale))
    div_max = Float.ceil(scalar.data_maximum / (tick_value * scalar.scale))

    range_check = (div_max - div_min <= allowed)

    factor_check and range_check
  end

  # Given a major and minor factor, the minor factor is adjusted to make
  # sure it is synchronized with the major factors.
  defp sync_ticks_option scalar do

    # Get tick factors.
    minor_factor = scalar.minor_factor
    major_factor = scalar.major_factor

    # Adjust minor factor if not synced to major.
    minor_factor = case scalar.sync do
      false ->
        minor_factor
      true ->
        scalar.factors
        |> Enum.filter(fn(x) -> x <= minor_factor end)
        |> Enum.find(fn(x) -> rem(x,major_factor) == 0 end)
    end

    struct(scalar, minor_factor: minor_factor)
  end

  defp finalize_values scalar do
    tick_value = 1.0/scalar.minor_factor
    div_min = Float.floor(scalar.data_minimum / (tick_value * scalar.scale))
    div_max = Float.ceil(scalar.data_maximum / (tick_value * scalar.scale))
    tick_start_value = div_min * tick_value * scalar.scale
    tick_count = round(div_max - div_min)

    # Place in structure.
    struct(scalar,
      tick_start_value: tick_start_value,
      tick_count: tick_count
    )
  end

  @doc """
  Generates a list of tuples, one for each tick. Info in the tuple is:

      {
        tick number,
        tick value (adjusted),
        magnitude,
        "major" | "minor"
      }

  """
  defp gen_tick_list scalar do
    minor_tick_value = 1.0 / scalar.minor_factor * scalar.scale
    tick_start_value = scalar.tick_start_value
    sync_factor = div(scalar.minor_factor, scalar.major_factor)
    magnitude = scalar.magnitude
    list = 0..scalar.tick_count
      |> Enum.map(fn(x) -> {x, tick_start_value + x * minor_tick_value, magnitude, tick_type(x,sync_factor)} end)

    struct(scalar,tick_list: list)
  end

  defp tick_type n, factor do
    case rem(n,factor) == 0 do
      true -> :major
      false -> :minor
    end
  end

end
