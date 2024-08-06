
defmodule GAME.Level do
  def blank() do
    %{}
  end
  def borders(level\\MapSet.new(),width,height) do
    cond do # let's do some checking because we ain't no fool
      !is_integer(width) || !is_integer(height) -> {:error, :wrong_type_dude}
      width < 1 || height < 1 -> {:error, :wrong_range_dude}
      true -> Map.merge(level, %{:borders => %{ :width => width-1 , :height => height-1 }})
    end
  end
  def walls_even(level) do
      width = level[:borders][:width]
      height = level[:borders][:height]
      setmap =  MapSet.new() # because we can't "into: MapSet.new()" insitu
      places = # places are map's squares that start at 0 
        for x <- 2..width//2 , 
        y <- 2..height//2 ,
        into: setmap do {x,y} end
      walls = %{:shape => :square, :breadth => 1, :places => places}
      dbg walls
      Map.merge(level, %{:walls => walls})
  end
  def blocks(level,ratio \\ 0.3) do
      width = level[:borders][:width]
      height = level[:borders][:height]
      setmap =  MapSet.new() # because we can't "into: MapSet.new()" insitu
      places = 
        for x <- 1..width , 
        y <- 1..height ,
        :rand.uniform() < ratio, # fill space one htird of time 
        # rem(x, 2) == 0 && rem(y, 2) == 0, # assuming we have wall on each odd , odd place  
        into: setmap do {x,y} end
      places = MapSet.difference places , level[:walls][:places] # remove block where there is wall
      blocks = %{:shape => :square, :breadth => 1, :places => places}
      Map.merge(level, %{:blocks => blocks})
  end
  # remove blocks and 
  def clear_spawning_spot(level,spot_place) do
    clear_place_and_adjacents = fn (set,x,y) -> 
    {spot_x,spot_y} = spot_place 
      Enum.filter(set, fn {x,y} -> # a vertical cross
        x < spot_x - 1 && spot_x + 1 < x && spot_y == y ||
        y < spot_y - 1 && spot_y + 1 < y && spot_x == x 
      end)
    end
    blocks = level[:blocks][:places]
    new_blocks = clear_spawning_spot(blocks,spot_place)
    walls = level[:walls][:places]
    new_walls = clear_spawning_spot(walls,spot_place)
    Map.replace(level, :blocks, new_blocks) 
    |> Map.replace(:walls ,new_walls)
  end
  def bomber(level,new_player) do
    players = case level[:players] do
      nil -> MapSet.new()
      _ -> level[:players]
    end 
    new_players = MapSet.put(players,new_player)
    dbg new_players
    Map.put(level, :players, new_players)
  end
end
defmodule GAME.Player do
  def player(ws_pid) do %{:ws => ws_pid} end
end
#   def bomber(level,player) do # add a player =  its web socket connection (pid) + define starting position
#     bomber = %{ :top_left => , :top_right, :bot_left, :bot_right }
#     Map.merge(level, %{: => blocks})
#     level
#   end
# end

level = GAME.Level.blank()
dbg level
level = GAME.Level.borders level, 5, 8
dbg level
level = GAME.Level.walls_odd level
dbg level
level = GAME.Level.blocks level, 0.50
dbg level
level = GAME.Level.player level, :dummy_ws_pid, {0.5,0.5}
dbg level
level = GAME.Level.player level, :stupud_ws_pid, {3.5,3.5}
dbg level



