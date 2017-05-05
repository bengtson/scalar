defmodule ScalarTest do
  use ExUnit.Case
  doctest Scalar

  test "simple check" do
    data = [0, 10]
    a = Scalar.create data, 10, 18
    assert a.minor_factor == 10
    assert a.major_factor == 10
  end

  test "simple check 2" do
    data = [0, 11]
    a = Scalar.create data, 10, 18
    assert a.minor_factor == 10
    assert a.major_factor == 5
  end

  test "check sync true" do
    data = [0, 1]
    a = Scalar.create data, 4, 5, [sync: true]
    assert a.minor_factor == 4
    assert a.major_factor == 4
  end

  test "check sync false stop major" do
    data = [0, 1]
    a = Scalar.create data, 4, 5, [sync: false, stop: :true]
    minor_list = Scalar.get_minor_tick_list a
    major_list = Scalar.get_major_tick_list a
    assert length(minor_list) == 6
    assert length(major_list) == 5
    assert a.minor_factor == 5
    assert a.major_factor == 4
  end

  test "check tick list major, minor" do
    data = [0,1]
    a = Scalar.create data, 2, 10
    list = Scalar.get_tick_list a
    assert length(list) == 11
    assert {_,_,_,:major} = Enum.at(list,0)
    assert {_,_,_,:minor} = Enum.at(list,1)
  end

  test "check tick list minor stop" do
    data = [0,1.2]
    a = Scalar.create data, 4, 10, [stop: :minor]
    list = Scalar.get_tick_list a
    assert length(list) == 6
    assert {_,_,_,:major} = Enum.at(list,0)
    assert {_,_,_,:minor} = Enum.at(list,5)
  end

  test "check tick list major stop" do
    data = [0,1.2]
    a = Scalar.create data, 4, 10, [stop: :major]
    list = Scalar.get_tick_list a
    assert length(list) == 7
    assert {_,_,_,:major} = Enum.at(list,0)
    assert {_,_,_,:major} = Enum.at(list,6)
  end

  test "tick list range" do
    {min, max} =
      [0,1.2]
      |> Scalar.create(4, 10, [stop: :major])
      |> Scalar.get_tick_list
      |> Scalar.get_tick_list_range
    assert min == 0.0
    assert max == 1.5
  end
end
