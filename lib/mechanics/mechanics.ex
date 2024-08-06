defmodule B.Mechanics do
  def level_updaters_from_fore_updater(previous_level,fore_updater,almanac_or_grid\\:almanac) do
    previous_level =
      case almanac_or_grid do
        :grid -> B.Level.almanac_to_grid(previous_level)
        :almanac -> B.Level.grid_to_almanac(previous_level)
      end
    
    updaters = Task.async_stream(previous_level, fore_updater, ordered: false)
    updaters = Stream.filter(updaters, fn
      {:ok, nil} -> false
      {:ok,_updater} -> true
      {:exit, _} -> false   # {:exit,_} returned stuff are removed
    end)
    updaters = Stream.map(updaters, fn {:ok,updater} -> updater end)
    updaters
  end
  def apply_updaters(level,updaters) do
    updated_level = Enum.reduce(updaters, level, fn
      updater,updating_level -> 
        updater.(updating_level)
    end)
    updated_level
  end
  def add_entities(%{:level => :almanac}=almanac, entities) do
    case entities do
      [] -> almanac
      [e|es] -> 
        new_almanac = put_in(almanac,[e[:id]],e)
        add_entities(new_almanac,es)
      unexpected -> 
        IO.warn "wrong data type #{inspect unexpected}" 
    end
  end

  def is_game_over(%{:level => :almanac}=almanac) do
    survivors = Enum.reduce(almanac,[],fn 
      {pid, %{:entity => :bomber}},player_pids -> [pid|player_pids]
      _, player_pids -> player_pids 
    end)
    case survivors do
      [] -> true
      [pid] -> 
        send(pid, :victory)
        true
      [_|_] -> false
    end
  end
end
  
