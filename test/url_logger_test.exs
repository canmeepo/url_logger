defmodule UrlLoggerTest do
  use ExUnit.Case
  doctest UrlLogger

  test "greets the world" do
    assert UrlLogger.hello() == :world
  end
end
