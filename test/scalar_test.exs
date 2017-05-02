defmodule ScalarTest do
  use ExUnit.Case
  doctest Scalar

  test "simple check" do
    data = [0, 10]
    a = Scalar.create data, 10, 18
    assert a.minor_tick_factor == 10
    assert a.major_tick_factor == 10
  end

  test "simple check 2" do
    data = [0, 11]
    a = Scalar.create data, 10, 18
    assert a.minor_tick_factor == 10
    assert a.major_tick_factor == 5
  end

  test "check sync true" do
    data = [0, 1]
    a = Scalar.create data, 4, 5, [sync: true]
    assert a.minor_tick_factor == 4
    assert a.major_tick_factor == 4
  end

  test "check sync false" do
    data = [0, 1]
    a = Scalar.create data, 4, 5, [sync: false]
    assert a.minor_tick_factor == 5
    assert a.major_tick_factor == 4
  end

  test "check tick list major, minor" do
    data = [0,1]
    a = Scalar.create data, 2, 10
    list = Scalar.get_tick_list a
    assert length(list) == 11
    assert {_,_,_,:major} = Enum.at(list,0)
    assert {_,_,_,:minor} = Enum.at(list,1)
  end

  test "check tick list major stop" do
    data = [0,1.2]
    a = Scalar.create data, 4, 10
    list = Scalar.get_tick_list a
    IO.inspect list
    assert length(list) == 11
    assert {_,_,_,:major} = Enum.at(list,0)
    assert {_,_,_,:minor} = Enum.at(list,1)
    assert 1==2
  end
end
