defmodule Scalar do

    @moduledoc """
    This is a scaler that can be used to determine the scaling for charts and
    graphs. When provided with a dataset and defined objectives, it will
    generate the necessary information for creating axis.

    TODO:
    - Handle tick list where sync is false.

    """
      def factors do
        [20, 10, 5, 4, 2, 1]
      end

    defstruct [
      factor_list: nil,
      minimum_value: nil,
      maximum_value: nil,
      range: nil,
      major_ticks_allowed: nil,
      minor_ticks_allowed: nil,
      minor_tick_factor: nil,
      major_tick_factor: nil,
      tick_low_index: nil,
      tick_high_index: nil,
      adjusted_range: nil,
      magnitude: nil,
      log: nil,
      sync: true,
      stop: :major,
      zero: true
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

    def create :data, data, major, minor, opts do
      {min, max} =
        data
        |> Enum.min_max
      create [min,max], major, minor, opts
    end

    def create data, major_ticks, minor_ticks, opts \\ [] do

      # Create structure for scalar.
      scalar = %Scalar{}

      # Append options.
      scalar = struct(scalar,opts)

      # Add a zero if a zero should be included in the range.
      data = case scalar.zero do
        true -> data ++ [0.0]
        false -> data
      end

      # Get the min and max for the data range.
      {min, max} =
        data
        |> Enum.min_max

      # Add factor list used.
      scalar = struct(scalar,
        factors: factors())

      # Add parameters to structure.
      scalar = struct(scalar,
        minimum_value: min,
        maximum_value: max,
        major_ticks_allowed: major_ticks,
        minor_ticks_allowed: minor_ticks
      )

      # Get value range and adjusted range.
      range =  max - min
      log = :math.log10 range
      magnitude = trunc(log)
      adjusted_range = :math.pow(10,log-magnitude)

      # Calculate the target minor and major tick values.
      target_minor_tick_value = adjusted_range / minor_ticks
      target_major_tick_value = adjusted_range / major_ticks

      # Find the best tick values based on the factor table. This will be the
      # most ticks without exceeding the specified maximum ticks allowed.
      minor_tick_factor =
        factors()
        |> Enum.find(fn(x) -> 1.0/x >= target_minor_tick_value end)

      major_tick_factor =
        factors()
        |> Enum.find(fn(x) -> 1.0/x >= target_major_tick_value end)

      # Adjust minor factor if not synced to major.
      minor_tick_factor = case scalar.sync do
        false ->
          minor_tick_factor
        true ->
          sync_minor_tick minor_tick_factor, major_tick_factor
      end

      struct(scalar,
        range: range,
        adjusted_range: adjusted_range,
        log: log,
        magnitude: magnitude,
        minor_tick_factor: minor_tick_factor,
        major_tick_factor: major_tick_factor,
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
    def get_tick_list %Scalar{sync: true} = scalar do
      minor_tick_value = 1.0 / scalar.minor_tick_factor
      sync_factor = div(scalar.minor_tick_factor, scalar.major_tick_factor)
      magnitude = scalar.magnitude
      list = 0..scalar.minor_ticks_allowed
        |> Enum.map(fn(x) -> {x, x * minor_tick_value, magnitude, tick_type(x,sync_factor)} end)

      # Trim the tick list to those specified by the caller.
      trim_ticks(list, scalar.adjusted_range, scalar.stop)
    end

    def get_tick_list %Scalar{sync: false} = scalar do
      # Where sync is false, what to do?
      minor_tick_value = 1.0 / scalar.minor_tick_factor
      sync_factor = div(scalar.minor_tick_factor, scalar.major_tick_factor)
      magnitude = scalar.magnitude
      0..scalar.minor_ticks_allowed
        |> Enum.map(fn(x) -> {x, x * minor_tick_value, magnitude, tick_type(x,sync_factor)} end)

      # Trim the tick list to those specified by the caller.
      trim_ticks(list, scalar.adjusted_range, scalar.stop)
    end

    defp trim_ticks list, value, type do
      val_index =
        list
        |> Enum.find_index(fn({_,val,_,_}) -> val >= value end)
      {keep_list,other_list} =
        list
        |> Enum.split(val_index)
      type_index =
        other_list
        |> Enum.find_index(fn({_,_,_,t}) -> t == type end)
      case type_index do
        nil ->
          [keep_list]
        _ ->

          {type_list,_} =
            other_list
            |> Enum.split(type_index + 1)
          keep_list ++ type_list
      end
    end


    defp tick_type n, factor do
      case rem(n,factor) == 0 do
        true -> :major
        false -> :minor
      end
    end

    # Given a major and minor factor, the minor factor is adjusted to make
    # sure it is synchronized with the major factors.
    defp sync_minor_tick minor_factor, major_factor do
      factors()
      |> Enum.filter(fn(x) -> x <= minor_factor end)
      |> Enum.find(fn(x) -> rem(x,major_factor) == 0 end)
    end

    def test do
      data = {0.0,95.0}
      a = create data, 10, 20, [stop: :major]
      get_tick_list a
    end

    def test2 do
      data = [4.5, 2.3, 7.8, 1.0, 3.0, 6.3]
      Scalar.create(:data, data, 10, 20, [sync: true, stop: :major])
      |> Scalar.get_tick_list
    end
  end
