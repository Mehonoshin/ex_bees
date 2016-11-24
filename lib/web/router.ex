defmodule Web.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "root route")
  end

  #forward "/world"

  match _ do
    send_resp(conn, 404, "oops")
  end
end
