Mix.install([
:plug, 
:bandit, 
])

defmodule Router do
  use Plug.Router
  use Plug.Builder
  plug Plug.Logger
  plug(Plug.Static,
    at: "",
    from: "./" 
    # only: ["chat.html.eex","gost.js","favicon.png"]
  )
  IO.puts "Poyoyoyoyog"
  plug :match
  plug :dispatch
  get "/" do
    IO.puts "asdas"
    # chat_port = "5555"
    # chat_path = "ws"
    html = EEx.eval_file("./bomberman.html.eex", 
      game_ws_port: "game_ws_port"  
    )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  match _ do
    IO.puts("failure")
    send_resp(conn, 404, "not found")
  end
  def page_get_port, do: 3333
  IO.puts "POYOYOYOYOG"
end


# IO.puts("bomberman page served on localhost:"<> inspect Router.page_get_port())
page_server = {Bandit, plug: Router, scheme: :http, port: 1111}
# bandit_router_7 = {Bandit , scheme: :http , plug: RouterBandit , port: 7777 }
{:ok, _} = Supervisor.start_link([page_server], strategy: :one_for_one)
Process.sleep(:infinity)
