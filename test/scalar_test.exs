defmodule ScalarTest do
  use ExUnit.Case
  doctest Scalar

  test "simple check" do
    data = [0, 10]
    a = Scalar.create data, 10, 20
    {min,max} = Scalar.get_tick_range a
    assert a.minor_factor == 20
    assert a.major_factor == 10
    assert min == 0.0
    assert max == 10.0
  end

  test "simple check 2" do
    data = [0, 11]
    a = Scalar.create data, 10, 18
    assert a.minor_factor == 10
    assert a.major_factor == 5
  end

  test "check tick list major, minor" do
    data = [0,1]
    a = Scalar.create data, 2, 10
    list = Scalar.get_tick_list a
    assert length(list) == 11
    assert {_,:major} = Enum.at(list,0)
    assert {_,:minor} = Enum.at(list,1)
  end

  test "inject zero option" do
    data = [5,11]
    a = Scalar.create data, 10, 18, [zero: true]
    assert a.minor_factor == 10
    assert a.major_factor == 5
  end

  test "non-zero positive scalar" do
    list = [579.54, 581.47]
    |> Scalar.create(10, 20, [])
    |> Scalar.get_tick_list

    assert length(list) == 9
    assert {581.5, :major} = Enum.at(list,8)
  end

  test "check negative, positive range" do
    list = [-5.0, 5.0]
    |> Scalar.create(10, 20)
    |> Scalar.get_tick_list

    assert length(list) == 21
    assert {5.0, :major} = Enum.at(list,20)
    assert {-5.0, :major} = Enum.at(list,0)
  end

  test "check inches scaling" do
    list = [579.54, 581.47]
    |> Scalar.create(10, 30, [factors: [12, 6, 4, 3, 2, 1]])
    |> Scalar.get_tick_list

    assert length(list) == 25
    assert {581.5, :major} = Enum.at(list,24)
  end
end
