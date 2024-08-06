defmodule B.Logic.Lobby do 
  def start_link() do #(init_state\\%{:players=>%{}}) do
    waiting_pid = spawn_link fn -> waiting(%{}) end
    Process.register(waiting_pid,:waiting_room )
    {:ok, self()}
  end

  def waiting(players) do
    # sollicitate players to update their ready state
    players = Map.filter(players, fn {player_pid, _} ->  Process.alive?(player_pid) end )
    receive do
      {:connect,player_pid} -> 
        players= Map.put_new(players, player_pid , false) 
        B.Logic.Chat.Room.spread("#{inspect player_pid}  player connected, 
        press start if you are ready to play")
        n_ready_players = Enum.count players, fn {_,ready?} -> ready? end
        n_not_ready_players = Enum.count players, fn {_,ready?} -> !ready? end
        B.Logic.Chat.Room.spread("#{inspect n_ready_players}  players are ready to start")
        B.Logic.Chat.Room.spread("#{inspect n_not_ready_players}  players are not ready to start")
        waiting(players)
      {:start,player_pid,readiness} -> 
        B.Logic.Chat.Room.spread("player #{inspect player_pid} #{bool_to_is_or_isnt(readiness)} ready to start a game")
        # B.Logic.Chat.Room.spread("#{inspect player_pid} is ready for a game")
        players = Map.replace!(players, player_pid, readiness)
        {ready_players,unready_players} = Map.split_with(players , fn {_,ready?} -> ready? end)
        case map_size(ready_players) == 4 do
          true -> 
            start_game_with_ready_players(ready_players)
            waiting(unready_players)
          false ->
            waiting(players)
        end
      _ ->
        IO.warn "received unexpected message in lobby waiting room"# #{inspect {unexpected}}"
    after
      wait(players) ->
        n_ready_players = Enum.count players, fn {_,ready?} -> ready? end
        case n_ready_players > 1 do 
          false ->
            B.Logic.Chat.Room.spread("waiting for more players to join")
            Enum.each(players, fn {player_pid , _} -> send(player_pid, {:start, :waiting_room}) end )
            waiting(players)
          true ->
            {ready_players,unready_players} = Map.split_with(players , fn {_,ready?} -> ready? end)
            start_game_with_ready_players(ready_players)
            waiting(unready_players) #start a new waiting room without the players that started to play 
        end
    end
  end

  def wait(players) do
    case map_size(players) do
      0 -> :infinity 
      1 -> :infinity 
      _ -> B.Constants.Lobby.wait()
    end
  end
    
  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
    }
  end

  def start_game_with_ready_players(ready_players) do
    Enum.each(ready_players, fn {player_pid,_} -> send(player_pid, :reset_start) end)
    list_pids = Enum.map(ready_players, fn {pid,_}->pid end)
    B.Logic.Chat.Room.spread("a game is starting with those players #{inspect list_pids}")
    B.Logic.Game.Loop.start(ready_players) 
  end
  
  def bool_to_is_or_isnt(true) do
    "is"
  end
  def bool_to_is_or_isnt(false) do
    "isn't"
  end
  
end
