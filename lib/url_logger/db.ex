defmodule UrlLogger.Db do
  def save(links) do
    keys = Redix.command!(:redix, ["TIME"])
    Redix.command!(:redix, ["ZADD", "links", List.first(keys), List.first(keys)])

    links
    |> Enum.filter(fn x -> valid_url?(x) end)
    |> Enum.each(fn x ->
      Redix.command!(:redix, ["LPUSH", List.first(keys), x])
    end)
  end

  def get(from, to) do
    links = Redix.command!(:redix, ["ZRANGEBYSCORE", "links", from, to])

    Enum.reduce(links, [], fn x, acc -> acc ++ Redix.command!(:redix, ["LRANGE", x, 0, -1]) end)
    |> Enum.map(fn x -> extractHostname(x) end)
  end

  @spec valid_url?(binary) :: boolean
  def valid_url?(url) do
    Regex.match?(
      ~r/^(([^:\/?#]+):\/\/)?([^\/?#]*)?([^?#]*)(\?([^#]*))?(#(.*))?$/u,
      url
    )
  end

  @spec extractHostname(binary | URI.t()) :: nil | binary
  def extractHostname(url) do
    cond do
      URI.parse(url).host == nil -> URI.parse(url).path
      URI.parse(url).host != nil -> URI.parse(url).host
    end
  end
end
