
defmodule B.Presentation.Page_server do
  alias B.Constants.Connection, as: C
  alias B.Constants.Folder, as: F
  use Plug.Router
  # use Plug.Builder
  # use Plug.Debugger
  # plug Plug.Logger
  IO.puts F.path_to_static()
  plug Plug.Static, at: "", from: F.path_to_static()
  plug :match
  plug :dispatch
  
  IO.puts("bomberman page served on localhost: http://localhost:#{C.pages_port()}")
  IO.puts(" - to only access frame : #{C.game_path()}")
  IO.puts(" - to only access gamepad : #{C.gamepad_path()}")
  IO.puts(" - to only access chat : #{C.chat_path()}")
  IO.puts(" - to only access game : #{C.game_path()}")
  
  # get C.main_path() do
  get "/" do
    IO.puts "getting request at /"
    html = EEx.eval_file(F.path_to_static()<>"main.html.eex", 
      ws_protocol: C.ws_protocol(), 
      ws_gamepad_port: C.ws_gamepad_port(), 
      ws_gamepad_path: C.ws_gamepad_path(), 
      ws_chat_port: C.ws_chat_port(), 
      ws_chat_path: C.ws_chat_path(), 
      ws_game_port: C.ws_game_port(), 
      ws_game_path: C.ws_game_path() 
    )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
  get C.chat_path() do
    IO.puts "getting request at /chat"
    html = EEx.eval_file(F.path_to_static()<>"chat.html.eex", 
      ws_protocol: C.ws_protocol(), 
      ws_chat_port: C.ws_chat_port(), 
      ws_chat_path: C.ws_chat_path() 
    )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
  get C.gamepad_path() do
    IO.puts "getting request at /gamepad"
    html = EEx.eval_file(F.path_to_static()<>"gamepad.html.eex", 
      ws_protocol: C.ws_protocol(), 
      ws_gamepad_port: C.ws_gamepad_port(), 
      ws_gamepad_path: C.ws_gamepad_path() 
    )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
  get C.game_path() do
    IO.puts "getting request at #{C.game_path()}"
    html = EEx.eval_file(F.path_to_static()<>"game.html.eex", 
      ws_protocol: C.ws_protocol(), 
      ws_game_port: C.ws_game_port(), 
      ws_game_path: C.ws_game_path() 
    )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  match _ do
    IO.puts("failure")
    send_resp(conn, 404, "not found")
  end
end

