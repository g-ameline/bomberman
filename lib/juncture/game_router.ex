################## UPGRADER ###############

defmodule B.Juncture.Game.Router do
  use Plug.Router
  plug Plug.Logger
  plug :match
  plug :dispatch
  get B.Constants.Connection.ws_game_path() do
    conn
    |> WebSockAdapter.upgrade(B.Juncture.Game.Handler, [], timeout: 600_000)
    |> halt()
  end

  match _ do
    IO.warn "failure"
    send_resp(conn, 404, "not found")
  end
end

################## handle message from client ###############
defmodule B.Juncture.Game.Handler do
  # require B.Juncture.Game.Router 
  def init(state) do
    {:ok, state}
  end

  # when client send direct message
  def handle_in({data, [opcode: :text]},state) do
    case Jason.decode(data) do
      {:ok,note} -> 
        case note do
          # get desired data and send it back
          %{"game" => game_pid} -> 
            game = B.Logic.Game.Issuer.request_game(B.Functions.string_to_pid(game_pid))
            case game do 
              nil -> {:push , {:text, "null"},state}
              %{} ->
                game = B.Level.grid_to_almanac(game)
                game = B.Level.format_positions(game)
                game_struct = %{:pid => game_pid, :game => game}
                game_as_message = B.Level.to_js_struct_message(game_struct)
                {:push , {:text, game_as_message},state}
            end
          "list" -> 
            list = B.Logic.Game.Issuer.request_list()
            list_pids_as_message = B.Level.to_js_struct_message(list)
            {:push, {:text,list_pids_as_message}, state}
          _unexpected -> IO.warn "unknown data #{inspect note}"
        end
      {:error,reason} ->
        IO.warn "failed at decoding json #{inspect reason}"
      _ -> IO.warn "WTF"
    end
  end
  ############### handle ws close ###############
  def terminate(_reason, state) do
   # will automatically trigger process.monitor's stop event and genserver will take this out
    {:ok, state}
  end
end

