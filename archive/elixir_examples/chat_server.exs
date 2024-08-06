Mix.install([
:plug, 
:bandit, 
:websock_adapter,
:jason
])

################## CHAT ROOM ###############
defmodule ChatRoom do
  use GenServer
  require Logger

################## CHAT API ###############
# function API that the others module can use
  # triggered by supervisor and himself start the module
  def start_link(init_state) do
    # will call the MODULE's init method and option as argument
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end
  def join() do
    # when join is called from outside
    # we call the internal gen server with the module name and the :join keyword
    GenServer.call(__MODULE__, :join)
  end

  def introduce(name) do
    # when user name itself, expectably right after upgrading ws
    # we call the internal gen server with the module name and the :name keyword
    GenServer.call(__MODULE__, {:name,name})
  end

  def spread(msg) do
    # when new message from user -> to be echoed to everyone = boradcast
    GenServer.call(__MODULE__, {:spread, msg})
  end

  @impl true
  def init(_init_state) do
    # is called wen gen server is initialized 
    # with start_link that passed its option parameters
    Logger.info("Creating the chat room")
    # the state is the list of "ws connected" clients 
    # start empty but will cons any newly joined client
    {:ok, %{}}
  end

################## INTERNAL LOGIC ###############

################## joining ###############

  @impl true
  def handle_call(:join, {caller_pid, _call_tag}, state) do
    IO.puts("received joining request")
    dbg state
    case state do
      %{caller_pid: _} -> 
        Logger.info("the client has already joined",caller_pid,state[caller_pid])
        {:noreply, {:error, :doucle_joining}, state}
      _ ->
        IO.puts("new client joining")
        IO.inspect(caller_pid)
        caller_ref = Process.monitor(caller_pid)
        IO.puts "pid"
        dbg caller_pid
        IO.puts "ref"
        dbg caller_ref
        # IO.inspect(state)
        state = Map.merge(state, %{caller_pid => %{:ref => caller_ref}})
        IO.inspect("new state")
        dbg state
        {:reply, :ok, state}
    end
  end

################## introduce ###############

  @impl true
  def handle_call({:name, new_name}, {caller_pid, _call_tag}, state) do
    IO.puts("received naming request")
    IO.puts new_name
    IO.puts("state")
    dbg state
    IO.puts("state.caller_pid")
    dbg caller_pid
    dbg state[caller_pid]
    case state do
      %{^caller_pid => _} -> 
        caller_value = Map.merge(state[caller_pid], %{:name => new_name})
        # caller_value = %{ state.caller_pid | :name => new_name}
        state = Map.merge(state, %{ caller_pid => caller_value})
        IO.puts "new state with name"
        dbg state
        # state = %{state | caller_pid => caller_values}
        {:reply, :ok, state}
      _ -> 
        Logger.warning("trying to introduce unjoined client")
        {:reply, :error, state}
    end
  end

################## spread the word ###############

  @impl true
  def handle_call({:spread, message}, {caller_pid, _call_tag}, state) do
    IO.puts("new message to spread")
    IO.inspect(message)
    dbg state
    case state do
      %{^caller_pid => _} -> 
        note = %{ :name => state[caller_pid][:name], message: message}
        IO.puts "note to spread"
        IO.inspect note
        case Jason.encode(note) do
          {:ok , json} -> 
            IO.puts "going to spread the message"
            dbg state[caller_pid]
            # IO.inspect Process.alive?(state[caller_pid])
            dbg json
            # loop into the colelction of callers (pid)
            # and ship message to each joined user
            Enum.map(state, fn {pid,_} -> {send(pid, json)}end)
            {:reply, :ok, state}
          {blunder, reason} ->
            IO.puts("failed to encode into JSON")
            ISO.inspect(blunder)
            ISO.inspect(reason)
            {:reply, :error, state}
        end
      _ -> 
        IO.puts("unjoined user")
        {:reply, :error, state}
    end
  end

  ######## fallback ########
  @impl true
  def handle_call(whatever, _, state) do
    IO.puts("unhandled call")
    IO.inspect(whatever)
    {:reply, :error, state}
  end

################## user left ###############

  @impl true
  # triggered by process monitor when process stop (-> websocket die)
  def handle_info({:DOWN, caller_ref, _, _, _}, state) do
    Logger.info("Peer left the room")
    # remove caller from state
    state = Map.reject(state, fn {_pid, ref_and_name} -> ref_and_name.ref == caller_ref end)
    {:noreply, state}
  end
end

################## WEBSOCKET HANDLER ###############

defmodule SocketHandler do
  require ChatRoom
  def init(state) do
    IO.puts("ini ws plug")
    IO.inspect(self())
    IO.inspect(state)
    ChatRoom.join()
    {:ok, state}
  end

################## handle message from client ###############

  # when client send direct message
  def handle_in({data, [opcode: :text]},state) do
    IO.puts("\nreceived data from client")
    IO.puts(data)
    IO.puts("trying to json decode")
    case Jason.decode(data) do
      {:ok,note} -> 
        IO.puts("succeeded at decoding json")
        IO.inspect(note)
        case note do
          %{"name" => name} -> ChatRoom.introduce(name)
          %{"message" =>  message} -> 
            ChatRoom.spread(message)
          _ -> IO.puts("unknown data"); IO.inspect(note)
        end
      {:error,reason} ->
        IO.puts("failed at decoding json")
        IO.inspect(reason)
      _ -> IO.puts("WTF")
    end
    {:ok, state}
  end

  def handle_info(message, state) do
    IO.puts "sending message into ws"
    dbg message
    {:push, {:text, message}, state}
  end

  ############### handle ws close ###############
  def terminate(_reason, state) do
   # will automatically trigger process.monitor's stop event and genserver will take this out
    {:ok, state}
  end
end

defmodule Router do
  use Plug.Router
  use Plug.Builder
  plug Plug.Logger
  plug(Plug.Static,
    at: "",
    from: "./" 
    # only: ["chat.html.eex","gost.js","favicon.png"]
  )
  plug :match
  plug :dispatch
  get "/" do
    # chat_port = "5555"
    # chat_path = "ws"
    html = EEx.eval_file("./chat.html.eex", chat_port: "5555", chat_path: "ws" )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  get "/ws" do
    conn
    |> WebSockAdapter.upgrade(SocketHandler, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    IO.puts("failure")
    send_resp(conn, 404, "not found")
  end
end

# require Logger
chat_room = {ChatRoom, nil}
chat_server = {Bandit, plug: Router, scheme: :http, port: 5555}
children = [chat_room,chat_server]
{:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
IO.puts("Plug now running on localhost:5555")
Process.sleep(:infinity)
