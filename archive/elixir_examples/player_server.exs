Mix.install([
:plug, 
:bandit, 
:websock_adapter,
:jason
])

defmodule Constants do
  # routing parameters
  def ws_protocol, do: "ws"
  def player_port, do: "4444" # ws and get page port for this unit test
  def ws_player_path,  do: "player"
  # inputs and commands atoms
  def direcions, do: MapSet.new([:still, :left, :right, :up, :down]) 
  _ = :bomb # input
  _ = :bombing  # state/command
end

################## WEBSOCKET HANDLER ###############

defmodule PlayerHandler do
  require Constants
  def init(command\\%{}) do
    IO.puts("\nini ws plug")
    IO.inspect(self())
    # create a clean command
    command = %{:direction => :still, :bombing => false}
    dbg command
    {:ok, command}
  end

################## handle message from client ###############

  # when client send direct message
  def handle_in({input, [opcode: :text]},command) do
    IO.puts("\nreceived input from client")
    dbg input # expect single word command
    dbg String.to_atom input
    input = String.to_atom input
    cond do 
      # Enum.member?(directions(), input)
      Enum.member?(Constants.direcions(), input) ->
        Map.merge(command ,%{:direction => input})
      input == :bombing ->
        Map.merge(command ,%{:bombing => true})
      true -> 
        IO.warn("input not in directions ?")
        dbg input
    end
    IO.puts "updated command after input"
    dbg command
    {:ok, command}
  end
  def handle_info({:direction,loop_pid}, command) do
    IO.puts "ws process received update direction inquiry from game's loop "
    send loop_pid , {:direction ,command[:direction]}
    {:ok, command}
  end
  def handle_info({:bombing,loop_pid}, command) do
    IO.puts "ws process received update bombing inquiry from game's loop "
    send loop_pid , {:bombing ,command[:bombing]}
    Map.merge(command ,%{:bombing => false})
    {:ok, command}
  end
  def handle_info(unexpected, state) do
    IO.puts "got unexpected inquiry something off"
    dbg unexpected
    {:ok, state}    
  end
end

################## ROUTER ###############

defmodule Router do
  use Plug.Router
  use Plug.Builder
  plug Plug.Logger
  plug(Plug.Static,
    at: "",
    from: "./" 
  )
  plug :match
  plug :dispatch
  get "/" do
    html = EEx.eval_file("./player.html.eex", 
      ws_protocol: Constants.ws_protocol(), 
      player_port: Constants.player_port(), 
      ws_player_path: Constants.ws_player_path()  
    )
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
  # get ws_player_path() do
  get "player" do
    conn
    |> WebSockAdapter.upgrade(PlayerHandler, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    IO.puts("failure")
    send_resp(conn, 404, "not found")
  end
end

page_server = {Bandit, plug: Router, scheme: :http, port: Constants.player_port()}
children = [page_server]
{:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
IO.puts("player page served on localhost:"<>Constants.player_port())
Process.sleep(:infinity)

