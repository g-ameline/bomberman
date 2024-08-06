defmodule B.Logic.Game.Issuer do
  use Agent

  def start_link(initial_value\\%{}) do
    # IO.puts "\nstart_link game issuer holder/server #{inspect initial_value}"
    Agent.start_link(fn -> initial_value end, name: :game_issuer)
    # IO.puts "game_issuer process pid#{inspect Process.whereis :game_issuer}"
    sanity_check()
  end

  def sanity_check() do
    Agent.cast(:game_issuer, fn games -> 
      Map.filter(games , fn {game_pid , _} -> Process.alive?(game_pid) end) 
    end)
    Process.sleep 30000
    sanity_check()
  end

  def update(game_pid, game_state) do
    # IO.puts "received game update demand"
    Agent.cast(:game_issuer, fn games ->  
        Map.put games, game_pid, game_state 
      end)
  end

  def remove(game_pid, game_state) do
    Agent.cast(:game_issuer,fn games ->  
      {_,updated_map} = Map.pop games, game_pid, game_state
      updated_map
    end)
  end

  def request_game(game_pid) do
    # IO.puts "a specific game state #{inspect game_pid} have been requested by #{inspect self()}"
    _game = Agent.get(:game_issuer, fn 
      %{^game_pid => game}=_games -> game
      _ -> nil 
    end)
  end
  
  def request_list() do
    # IO.puts "a list of games have been requested by #{inspect self()}"
    _game = Agent.get(:game_issuer, fn games -> 
      Map.keys(games) end)
  end
end

