defmodule UrlLogger.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts UrlLogger.Router.init([])
  @links ["https://test.ru", "http://test1.ru", "test.ru"]
  @ok "{\"status\":\"ok\"}"

  test "should returns 200, status ok and empty array" do
    conn = conn(:get, "/visited_domains?from=1545221231&to=1545217638")

    conn = UrlLogger.Router.call(conn, @opts)

    assert conn.status == 200
    assert conn.resp_body == "{\"status\":\"ok\",\"domains\":[]}"
  end

  test "should returns 422 when get query without params" do
    conn = conn(:get, "/visited_domains")

    conn = UrlLogger.Router.call(conn, @opts)

    assert conn.status == 422
    assert conn.resp_body == "{\"error\":\"Expected query params: ?from=...&to=...\"}"
  end

  test "should returns 200 and status ok when paylod is valid" do
    conn = conn(:post, "/visited_links", %{links: @links})

    conn = UrlLogger.Router.call(conn, @opts)

    assert conn.status == 200
    assert conn.resp_body == @ok
  end

  test "should returns 422 with an invalid payload" do
    conn = conn(:post, "/visited_links", %{})

    conn = UrlLogger.Router.call(conn, @opts)

    assert conn.status == 422
  end

  test "should returns 404 when no route matches" do
    conn = conn(:get, "/fail")

    conn = UrlLogger.Router.call(conn, @opts)

    assert conn.status == 404
  end
end
