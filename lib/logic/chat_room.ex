defmodule B.Logic.Chat.Room do
  use GenServer

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
    # the state is the list of "ws connected" clients 
    # start empty but will cons any newly joined client
    {:ok, %{}}
  end

################## INTERNAL LOGIC ###############

################## joining ###############

  @impl true
  def handle_call(:join, {caller_pid, _call_tag}, state) do
    case state do
      %{caller_pid: _} -> 
        {:noreply, {:error, :doucle_joining}, state}
      _ ->
        caller_ref = Process.monitor(caller_pid)
        state = Map.merge(state, %{caller_pid => %{:ref => caller_ref}})
        IO.inspect("new state #{inspect(state)}")
        
        welcome_note = %{ :name => "SERVER", :message => 
          "Hi, you joined the chat (only),
          to join a game, please create a 'gamepad'
          by clicking on one of the 4 butouns. 
          Different keyboard scheme are available by default:
          wasd, tfgh, uhjk, and arrows.
          for exanple the wasd bindings works like that :
          Q W E
          A S D
          Q is enter (press 1 time to enlist for a game)
          E is dropping a bomb
          W is move up, S down, A left and D right
          you can hover the key icon to see the keycode,
          you can change it by pressing the desired key while hovering,
          hopefully you will figure out the rest yourself."
        }
        send(caller_pid, Jason.encode!(welcome_note) )
        {:reply, :ok, state}
      end
  end

################## introduce ###############

  @impl true
  def handle_call({:name, new_name}, {caller_pid, _call_tag}, state) do
    case state do
      %{^caller_pid => _} -> 
        caller_value = Map.merge(state[caller_pid], %{:name => new_name})
        state = Map.merge(state, %{ caller_pid => caller_value})
        {:reply, :ok, state}
      unexpected-> 
        IO.warn "unknown name #{inspect unexpected}"
        {:reply, :error, state}
    end
  end

################## spread the word ###############

  @impl true
  def handle_call({:spread, message}, {caller_pid, _call_tag}, state) do
    case state do
      %{^caller_pid => _} -> 
        note = %{ :name => state[caller_pid][:name], message: message}
        case Jason.encode(note) do
          {:ok , json} -> 
            # loop into the collection of callers (pid)
            # and ship message to each joined user
            Enum.map(state, fn {pid,_} -> {send(pid, json)} end)
            {:reply, :ok, state}
          {other, reason} ->
            IO.warn "failed to json data #{inspect other} #{inspect reason}"
            {:reply, :error, state}
        end
      _sender_not_chat_member -> 
        note = %{ :name => "SERVER", :message => message }
        Enum.map(state, fn {pid,_} -> {send(pid, Jason.encode!(note))} end)
        {:reply, :ok, state}
    end
  end

  ######## fallback ########
  @impl true
  def handle_call(unexpected, _, state) do
    IO.warn "unexpected call #{inspect unexpected}"
    {:reply, :error, state}
  end

################## user left ###############

  @impl true
  # triggered by process monitor when process stop (-> websocket die)
  def handle_info({:DOWN, caller_ref, _, _, _}, state) do
    # remove caller from state
    state = Map.reject(state, fn {_pid, ref_and_name} -> ref_and_name.ref == caller_ref end)
    {:noreply, state}
  end
end


