defmodule Web.Map do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  defp html do
    case File.read("lib/web/templates/map.html") do
      {:ok, html} -> html
      {error, reason} -> "#{error} #{reason}"
    end
  end
end

