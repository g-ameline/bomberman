################## WEBSOCKET HANDLER ###############

defmodule B.Logic.Command_holder do
  alias B.Constants.Commands, as: C 
  def init(_whatever) do
    command_state = %{:orientation => :still, :bombing => false, :start=>false}
    # need to register to lobby process
    send :waiting_room, {:connect, self()}
    # sending pid to client to it can color the gamepad accordingly (same as player)
    {:push, {:text,B.Functions.pid_to_string(self())},command_state}
  end

################## handle message from client ###############

# command_state is %{
  #:orientation => :left | :rigth ...
  # bombing => true | false
  # start => true | false
#}
  # when client send direct message
  def handle_in({input, [opcode: :text]},command_state) do
    input = String.to_atom input
    command_state = cond do 
      Enum.member?(C.orientations(), input) ->
        Map.put(command_state , :orientation , input)
      input == :bomb ->
        Map.put(command_state , :bombing, true)
      input == :start ->
        Map.update(command_state , :start, false, fn x -> !x end)
      true -> 
        IO.warn("unexpected input ? #{inspect input}")
    end
    {:ok, command_state}
  end
  
  def handle_info({:all,caller_pid}, command_state) do
    send caller_pid, {:all, command_state}
    {:ok , command_state}
  end
  
  def handle_info({:orientation,caller_pid}, command_state) do
    send caller_pid , {:orientation ,command_state[:orientation]}
    {:ok , command_state}
  end
  
  def handle_info({:bombing,caller_pid}, command_state) do
    send caller_pid , {:bombing ,command_state[:bombing]}
    {:ok , command_state}
  end
  
  def handle_info({:reset_bombing}, command_state) do
    # send caller_pid , {:bombing ,command_state[:bombing]}
    command_state = Map.merge(command_state ,%{:bombing => false})
    {:ok , command_state}
  end
  
  def handle_info({:start,caller_pid}, command_state) do
    send caller_pid , {:start ,self() , command_state[:start]}
    {:ok , command_state}
  end
  
  def handle_info(:reset_start, command_state) do
    command_state = Map.replace(command_state ,:start , false)
    {:ok , command_state}
  end
  
  def handle_info(:lost, command_state) do
    # we turn off that controller, client is expected to restart a new one
    {:stop, :normal, 1000, {:text,"lost"}, command_state}
  end
  def handle_info(:victory, command_state) do
    # we turn off that controller, client is expected to restart a new one
    {:stop, :normal, 1000, {:text,"victory"}, command_state}
    # {:stop, reason :: term(), close_detail(), messages(), state()}
  end
  def handle_info(unexpected, command_state) do
    IO.warn"got unexpected inquiry something off #{inspect unexpected}"
    {:ok , command_state}
  end
end


