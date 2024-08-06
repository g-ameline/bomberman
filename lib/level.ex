defmodule B.Level do
  def grid() do
    %{:level=>:grid}
  end
  def grid({w,h}) do
    %{:level=>:grid,
      :width => w,
      :height => h }
  end
  def grid(w,h), do: grid({w,h})
  
  def almanac() do
    %{:level=>:almanac}
  end
  def almanac({w,h}) do
    %{:level=>:almanac,
      :width => w,
      :height => h }
  end
  def almanac(w,h), do: almanac({w,h})
  
  def grid_to_almanac(%{:level => :grid}=level) do
    Map.new(level,fn 
      {_position,%{:id=>id}=entity} -> {id,entity}
      {:level,:grid} -> {:level,:almanac}
      other -> other
    end)
  end

  def grid_to_almanac(%{:level => :almanac}=level), do: level
  
  def format_positions(%{:level => :almanac}=almanac) do
    Map.new(almanac,fn 
      {id, %{:entity => :bomber, :position => {_x,_y,_d}}=bomber} -> 
        { id , Map.update!(bomber, :position, fn position -> B.Vectors.to_float(position) end) }
      other -> other
    end)
  end

  def split_by_entities(%{:level => :almanac}=almanac) do
    {bombers, rest} = 
      Map.split_with(almanac, fn 
        {_id,%{:entity => :bomber}} -> true
        _ -> false
      end)
    {flames, rest} = 
      Map.split_with(rest, fn 
        {_id,%{:entity => :flame}} -> true
        _ -> false
      end)
    {bombs, rest} = 
      Map.split_with(rest, fn 
        {_id,%{:entity => :bomb}} -> true
        _ -> false
      end)
    {blocks, rest} = 
      Map.split_with(rest, fn 
        {_id,%{:entity => :block}} -> true
        _ -> false
      end)
    # {walls, rest} = 
    #   Map.split_with(rest, fn 
    #     {_id,%{:entity => :wall}} -> true
    #     _ -> false
    #   end)
    {bonuses, rest} = 
      Map.split_with(rest, fn 
        {_id,%{:entity => :bonus}} -> true
        _ -> false
      end)
    %{:bombers => Map.put(bombers, :level, :almanac),
      :flames => Map.put(flames, :level, :almanac),
      :bombs => Map.put(bombs, :level, :almanac),
      :blocks => Map.put(blocks, :level, :almanac),
      # :walls => Map.put(walls, :level, :almanac),
      :bonuses => Map.put(bonuses, :level, :almanac),
      :rest => rest
    }
  end

  def almanac_to_grid(%{:level => :almanac}=level) do
    Enum.reduce(level,%{}, fn 
      {id,%{:id => id,:position => position}=entity},acc_grid ->
        Map.put_new(acc_grid,position,%{})
        put_in(acc_grid,[position,id],entity)
      {:level,:almanac},acc_grid -> 
        Map.put(acc_grid,:level,:grid)
      {k,_v}=meta_data,acc_grid -> 
        Map.put(acc_grid,k,meta_data)
    end)
  end
  def almanac_to_grid(%{:level => :grid}=level), do: level
  
  def to_js_struct_message(data) do
    case data do
      %{:level => :grid} -> grid_to_almanac(data)
      _-> data
    end
    |> format()
  end
  
  def format(data) do 
    case data do
      str when is_bitstring(str) -> "'#{str}'" 
      pid when is_pid(pid) -> format(B.Functions.pid_to_string(pid))
      ato when is_atom(ato) -> format(Atom.to_string(ato))
      tup when is_tuple(tup) -> 
        Tuple.to_list(tup) 
        |> Enum.map(fn ele -> format(ele) end)
        |> inspect()
      lis when is_list(lis) -> "((new Set())" <>
        Enum.reduce(lis,"", fn elem,result ->
          ".add(#{format elem})"<>result
        end)<>")"
      map when is_map(map) ->  "( (new Map())" <> 
        Enum.reduce(map,"", fn {key,val},result ->
          ".set(#{format key},#{format val})"<>result
        end)<>")"
      other -> to_string(other)
    end
  end
  
  def level_from_players(players) do 
    {width,height} = width_and_height (Enum.count players)
    players_pids = Map.keys players
    _level = B.Level.almanac({width,height})
    |> place_bombers(players_pids)
    |> place_borders()
    |> place_pillars()
    |> place_blocks()
    |> clear_spawning_spots()
  end 
 
  def width_and_height(_number_players) do
    {7,7}
    # {_width , _height} = {(number_players*2) + 3 , (number_players*2) + 3}
  end

  def place_borders(%{:level=>:almanac}=level) do
    w = level[:width]
    h = level[:height]
    places = 
      for i <- [0,w+1],
      j <- 0..h+1,
      do: {i,j}
    level = Enum.reduce(places, level, fn {i,j},acc_level -> 
      add_entity(acc_level, B.Entities.new_wall( {i,j} ) )
    end)
    places = 
      for i <- 1..w,
      j <- [0,h+1],
      do: {i,j}
    _level = Enum.reduce(places, level, fn {i,j},acc_level -> 
      add_entity(acc_level, B.Entities.new_wall( {i,j} ) )
    end)
  end

  def place_pillars(%{:level=>:almanac}=level) do
    w= level[:width]
    h= level[:height]
    places = 
      for i <- 2..w//2,
      j <- 2..h//2,
      do: {i,j}
    level = Enum.reduce(places, level, fn {i,j}, acc_level -> 
      add_entity(acc_level, B.Entities.new_wall( {i,j} ) )
    end)
    level
  end
  
  def place_blocks(%{:level=>:almanac} = level,ratio\\0.6) do
    w = level[:width]
    h = level[:height]
    places = 
      for i <- 1..w, 
      j <- 1..h,
      rem(i, 2) == 1 or rem(j, 2) == 1, # assuming we have wall on each {odd,odd} place
      :rand.uniform() < ratio, # fill space one htird of time
      do: {i,j}
    level =
      Enum.reduce(places, level, fn {i,j},acc_level -> 
        add_entity(acc_level, B.Entities.new_block( {i,j} ) )
      end)
    level
  end

  def place_bombers(%{:level=>:almanac}=level,players_pid) do
    w = level[:width]
    h = level[:height]
    start_positions = start_positions(w,h,Enum.count(players_pid))
    place_pid = Enum.zip(start_positions,players_pid) # [{i,j},pid]
    Enum.reduce(place_pid,level,
      fn {{i,j},pid},acc_level -> 
        Map.put(acc_level,pid,B.Entities.new_bomber(pid,{i,j})) 
    end)
  end
  
  def clear_spawning_spots(%{:level => :almanac}=level) do
    w = level[:width]
    h = level[:height]
    spots_to_clear = 
      Enum.reduce(level,[], fn 
        {_k, %{:entity => :bomber, :position => {x,y}}},acc -> 
          spots = 
            for i <- [-1,0,+1],
            j <- [-1,0,+1],
            i*j == 0,
            0 < i+x and i+x <= w,
            0 < j+y and j+y <= h,
            do: {x+i,y+j}
          spots ++ acc
        _,acc -> acc
      end)
    Map.reject(level,
      fn 
        {_k , %{:entity => :bomber } } -> false
        {_k , %{:position => {i,j} } } -> {i,j} in spots_to_clear 
        _ -> false
    end)
  end
  
  def start_positions(w,h,n) do 
    Enum.take([{w, h},{1, 1},{w, 1},{1, h},{round(w/2),round(h/2)}],n)
  end
  
  def add_entity(%{:level => :grid}=level,%{:id => id,:position => position }=entity) do
    put_in(level,[position,id],entity)
  end
  def add_entity(%{:level => :almanac}=level,%{:id => id}=entity) do
    Map.put(level,id,entity)
  end

end

