defmodule Scalar do

    @moduledoc """
    This is a scaler that can be used to determine the scaling for charts and
    graphs. When provided with a dataset and defined objectives, it will
    generate the necessary information for creating axis.

    TODO:
    - Handle tick list where sync is false.

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
      magnitude: nil,
      log: nil,
      minor_target: nil,
      major_target: nil,
      minor_factor: nil,
      major_factor: nil,
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

    def create data, major_allowed, minor_allowed, opts \\ [] do

      %Scalar{}
      |> struct(opts)
      |> struct(data: data)
      |> struct(major_allowed: major_allowed, minor_allowed: minor_allowed)
      |> inject_zero_option
      |> calc_key_parameters
      |> layout_ticks
      |> sync_ticks_option

    end

    defp inject_zero_option scalar do
      case scalar.zero do
        true -> struct(scalar, data: [0.0] ++ scalar.data)
        false -> scalar
      end
    end

    defp calc_key_parameters scalar do
      {min, max} = scalar.data |> Enum.min_max
      range = max - min
      log = :math.log10 range
      magnitude = trunc(log)
      normalized_range = :math.pow(10,log-magnitude)

      struct(scalar,
        data_minimum: min,
        data_maximum: max,
        range: range,
        log: log,
        magnitude: magnitude,
        normalized_range: normalized_range
      )
    end

    defp layout_ticks scalar do

      # Set tick target value.
      normalized_range = scalar.normalized_range
      minor_target = normalized_range / scalar.minor_allowed
      major_target = normalized_range / scalar.major_allowed

      # Find the best tick values based on the factor table. This will be the
      # most ticks without exceeding the specified maximum ticks allowed.
      minor_factor =
        scalar.factors
        |> Enum.find(fn(x) -> 1.0/x >= minor_target end)

      major_factor =
        scalar.factors
        |> Enum.find(fn(x) -> 1.0/x >= major_target end)

      # Place in structure.
      struct(scalar,
        minor_target: minor_target,
        major_target: major_target,
        minor_factor: minor_factor,
        major_factor: major_factor
      )
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
      minor_tick_value = 1.0 / scalar.minor_factor
      sync_factor = div(scalar.minor_factor, scalar.major_factor)
      magnitude = scalar.magnitude
      list = 0..scalar.minor_allowed
        |> Enum.map(fn(x) -> {x, x * minor_tick_value, magnitude, tick_type(x,sync_factor)} end)

      # Trim the tick list to those specified by the caller.
      trim_ticks(list, scalar.normalized_range, scalar.stop)
    end

    def get_minor_tick_list scalar do
      # Where sync is false, what to do?
      minor_tick_value = 1.0 / scalar.minor_factor
      magnitude = scalar.magnitude
      list =
        0..scalar.minor_allowed
        |> Enum.map(fn(x) -> {x, x * minor_tick_value, magnitude, :minor} end)

      # Trim the tick list to those specified by the caller.
      trim_ticks(list, scalar.normalized_range, scalar.stop)
    end

    def get_major_tick_list scalar do
      # Where sync is false, what to do?
      major_tick_value = 1.0 / scalar.major_factor
      magnitude = scalar.magnitude
      list =
        0..scalar.major_allowed
        |> Enum.map(fn(x) -> {x, x * major_tick_value, magnitude, :major} end)

      # Trim the tick list to those specified by the caller.
      trim_ticks(list, scalar.normalized_range, scalar.stop)
    end

    defp trim_ticks list, value, type do
      type = case type do
        true ->
          [{_,_,_,stop} | _] = list
          stop
        _ ->
          type
      end
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

    def test do
      data = {0.0,95.0}
      a = create data, 10, 20, [stop: :major]
      get_tick_list a
    end

    def test2 do
      data = [4.5, 2.3, 7.8, 1.0, 3.0, 6.3]
      Scalar.create(data, 10, 20)
      |> Scalar.get_tick_list
    end
  end
