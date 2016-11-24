defmodule Web.WorldRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/map" do
    Web.Map.call(conn, [])
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
