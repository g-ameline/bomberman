################## SERVER ###############
defmodule B.Juncture.Chat.Server do
  use Plug.Router
  plug Plug.Logger
  plug :match
  plug :dispatch
  get B.Constants.Connection.ws_chat_path() do
    conn
    |> WebSockAdapter.upgrade(B.Juncture.Chat.Handler, [], timeout: 600_000)
    |> halt()
  end

  match _ do
    IO.warn "failure"
    send_resp(conn, 404, "not found")
  end
end

################## HANDLER ###############

defmodule B.Juncture.Chat.Handler do
  def init(no_state) do
    IO.inspect(self())
    B.Logic.Chat.Room.join()
    {:ok, no_state}
  end

  # when client send direct message
  def handle_in({data, [opcode: :text]},no_state) do
    case Jason.decode(data) do
      {:ok,note} -> 
        case note do
          %{"name" => name} -> B.Logic.Chat.Room.introduce(name)
          %{"message" =>  message} -> 
            B.Logic.Chat.Room.spread(message)
        end
      {:error,reason} ->
        IO.warn "failed to json node #{reason}"
    end
    {:ok, no_state}
  end

  def handle_info(message, no_state) do
    {:push, {:text, message}, no_state}
  end

  ############### handle ws close ###############
  def terminate(_reason, no_state) do
   # will automatically trigger process.monitor's stop event and genserver will take this out
    {:ok, no_state}
  end
end

