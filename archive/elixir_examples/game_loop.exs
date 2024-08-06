
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
  def orientations, do: {:still, :left, :right, :up, :down} 
  _ = :bomb # input
  _ = :bombing  # state/command ~`player want to drop a bomb`
  
  def frame_span, do: 150 # ms target 15 
  # game starting parameters
  def lives, do: 3 #  
  def bombs, do: 1 #  
  def speed, do: 0.3 # how many unit per frame 
  def grace, do: 0.3 # immunity after life loss
  # game logic parameters
  def tarry, do: 60 # how many frames 
  def lingering, do: 6 # how many frames before diseapear
  def incubation, do: 3 # how many frames before spawning neighbor 
  def bonuses, do: {:speed,:bombs,:flame} #upgrade speed numer of bombs or bomb extent
end

defmodule Loop do
  require Time
  #start the game loop()
  def start(level_data) do
    spawn(fn -> loop(level_data) end)
  end

  def loop(last_state) do
    {tick_start_calcul,_} = time.utc_now().microsecond
    %{:bombers => bombers,
      :walls => walls,
      :blocks => blocks,
      :flames => flames,
      :bombs => bombs,
      :bonuses => bonuses,
    } = last_state
      # update 
    {tick_end_calcul,_} = time.utc_now().microsecond
    calcul_time = tick_end_calcul - tick_start_calcul
    advance = calcul_time - frame_span
    IO.puts("loop processed in"+inspect(advance)+"ms")
    next_state = %{:bombers => bombers,
      :walls => walls,
      :blocks => blocks,
      :flames => flames,
      :bombs => bombs,
      :bonuses => bonueses,
    } 
    #### listening phase 
    # hopfully we have some extra time before net loop must start
    next_state = receive do
      {:orientation,player_pid} -> update_orientation(:ok,next_state)
      {:bombing,player_pid} -> update_bombing(:ok,next_state)
      {:broadcast,ws_pid} -> share_state(:ok,next_state)
      unexpected -> IO.warn("WTF?"++unexpected)
    after
        advance -> loop(next_state)
    end
    #### wait a little if the loop went faster that what target fps need
  end
end

################## WEBSOCKET HANDLER ###############

defmodule Gamepad_handler do
  alias Constants.orientations
  def init(command\\%{}) do
    IO.puts("\init ws plug")
    IO.inspect(self())
    # create a clean command
    command = %{:orientation => :still, :bombing => false}
    dbg command
    {:ok, command}
  end

################## handle message from client ###############

  # when client send direct message
  def handle_in({input, [opcode: :text]},command) do
    IO.puts("\nreceived input from client")
    dbg input # expect single word command
    dbg String.to_atom input
    cond do 
      Enum.member?(orientations, input)
        Map.merge(command ,%{:orientation => input})
      input == :bombing
        Map.merge(command ,%{:bombing => true})
    end
    IO.puts "updated command after input"
    dbg command
    {:ok, state}
  end
  def handle_info({:orientation,self(),loop_pid}, command) do
    IO.puts "ws process received update orientation inquiry from game's loop "
    send loop_pid , {:orientation ,command[:orientation]}
    {:ok, command}
  end
  def handle_info({:bombing,self(),loop_pid}, command) do
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
      ws_protocol: Constant.ws_protocol(), 
      player_port: Constant.player_port(), 
      ws_player_path: Constant.ws_player_path()  
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

page_server = {Bandit, plug: Router, scheme: :http, port: Constant.player_port()}
children = [page_server]
{:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
IO.puts("player page served on localhost:"<>Constant.player_port())
Process.sleep(:infinity)


