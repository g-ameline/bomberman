
defmodule B.Juncture.Gamepad.Router do
  use Plug.Router
  plug Plug.Logger
  plug :match
  plug :dispatch
  get B.Constants.Connection.ws_gamepad_path() do
    conn
    |> WebSockAdapter.upgrade(B.Logic.Command_holder, [], timeout: 600_000)
    |> halt()
  end

  match _ do
    IO.warn "failure"
    send_resp(conn, 404, "not found")
  end
end


