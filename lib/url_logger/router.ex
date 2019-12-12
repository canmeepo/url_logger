defmodule UrlLogger.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  @from "from"
  @to "to"
  @links "links"
  @content_type "application/json"

  get "/visited_domains" do
    conn
    |> fetch_query_params

    {status, body} =
      case conn.query_params do
        %{@from => from, @to => to} -> {200, process_get(from, to)}
        _ -> {422, missing_query()}
      end

    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(status, body)
  end

  post "/visited_links" do
    {status, body} =
      case conn.body_params do
        %{@links => links} -> {200, process_links(links)}
        _ -> {422, missing_links()}
      end

    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(status, body)
  end

  defp process_get(from, to) do
    domains = UrlLogger.Db.get(from, to)
    Poison.encode!(%{status: "ok", domains: domains})
  end

  defp process_links(links) when is_list(links) do
    UrlLogger.Db.save(links)
    Poison.encode!(%{status: "ok"})
  end

  defp process_links(_) do
    Poison.encode!(%{response: "Please send some links"})
  end

  defp missing_links do
    Poison.encode!(%{error: "Expected Payload: { 'links': [...] }"})
  end

  defp missing_query do
    Poison.encode!(%{error: "Expected query params: ?from=...&to=..."})
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    conn
    |> send_resp(400, "Bad request")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
