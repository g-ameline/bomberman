defmodule B.Mechanics.Flame do
end
defmodule B.Mechanics.Flame.Burst do
alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomb, :expiry => 0, :range => range, :position => place }->   
        orientations = B.Constants.Commands.orientations()
        next_places = 
          Enum.map(orientations,fn orient -> V.direction(orient) end)
          |> Enum.map(fn x_y -> V.add(x_y,place)end)
        next_flames = 
          Enum.zip(orientations,next_places)
          |>  Enum.map(fn {orient,place} -> B.Entities.new_flame(orient,range,place) end)
        fn 
          %{}=almanac -> B.Mechanics.add_entities(almanac,next_flames)
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Flame.Spread do
  alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :flame, :range => 0 }=_flame-> 
          nil
      %{:entity => :flame, :orientation => :still }=_flame-> 
          nil
      %{:entity => :flame,:range => range , :incubation => 0, 
        :position => place, :orientation => orientation
      }=_flame -> 
        next_place = V.add(place,V.direction(orientation)) 
        next_flame = B.Entities.new_flame(orientation,range-1,next_place) 
        fn 
          %{}=almanac -> Map.put(almanac,next_flame[:id],next_flame)
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Flame.Consume do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :flame, :id => flame_id, :position => place}-> 
        overlap_something? = Enum.any?(almanac, fn 
          {_id,%{:position => ^place, :entity => entity}=_stuff} -> 
            entity in [:block, :wall, :bomb] 
          {_id,_not_an_entity}=_element -> 
            false 
        end)
        case overlap_something? do
          false -> nil
          true -> 
            fn 
              %{}=almanac -> 
                {_key_or_nil,result} = pop_in(almanac,[flame_id])
                result 
            end
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity,level) end )
  end
end
defmodule B.Mechanics.Flame.Decay do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :flame, :id => flame_id, :expiry => _}-> 
        fn 
          %{^flame_id => _}=almanac -> 
            update_in(almanac,[flame_id,:expiry],fn expiry -> (expiry - 1) end) 
          map_without_the_flame -> map_without_the_flame 
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Flame.Incubate do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :flame, :id => flame_id, :incubation=> _} -> 
        fn 
          %{^flame_id => _}=almanac -> 
            update_in(almanac,[flame_id,:incubation],fn incubation -> (incubation - 1) end) 
          map_without_the_flame -> map_without_the_flame 
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end


defmodule B.Mechanics.Flame.Ignite do
alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bomb, :position => place, :range => range}-> 
        bomb_overlap_flame? = Enum.any?(almanac, fn 
          {_id,%{:position => ^place, :entity => :flame}} -> 
            true
          {_id,_not_a_flame}=_element -> 
            false 
        end)
        case bomb_overlap_flame? do
          false -> nil
          true -> 
            orientations = B.Constants.Commands.orientations()
            next_places = 
              Enum.map(orientations,fn orient -> V.direction(orient) end)
              |> Enum.map(fn x_y -> V.add(x_y,place)end)
            next_flames = 
              Enum.zip(orientations,next_places)
              |>  Enum.map(fn {orient,place} -> B.Entities.new_flame(orient,range,place) end)
            fn 
              %{}=almanac -> B.Mechanics.add_entities(almanac,next_flames)
            end
        end
      _not_a_bomb -> nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity,level) end )
  end
end

defmodule B.Mechanics.Flame.Remove do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :flame, :id => flame_id, :expiry => 0}-> 
        fn 
          %{}=almanac -> 
            {_key_or_nil,result} = pop_in(almanac,[flame_id])
            result 
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(almanac) do
    B.Mechanics.level_updaters_from_fore_updater(almanac,fn entity-> fore_updater(entity) end )
  end
end
