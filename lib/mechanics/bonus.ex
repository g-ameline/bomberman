defmodule B.Mechanics.Bonus do
end
defmodule B.Mechanics.Bonus.Drop do
# callback to map over each level's element to create an updater function
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :block, :position => place}-> 
        overlap_something? = Enum.any?(almanac, fn 
          {_id,%{:position => ^place, :entity => entity}=_stuff} -> 
            entity == :flame 
          {_id,_not_an_entity}=_element -> 
            false 
        end)
        case overlap_something? do
          false -> nil
          true -> 
            case :rand.uniform() < B.Constants.Bonus.drop_chance() do
              true -> 
                new_bonus = B.Entities.new_bonus(place)
                fn %{}=almanac -> Map.put(almanac,new_bonus[:id],new_bonus) end
              false ->
                nil 
            end
        end
      _not_flame_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity,level) end )
  end
end

defmodule B.Mechanics.Bonus.Remove do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bonus, :position => place, :id => bonus_id} -> 
        is_looter = 
          Enum.find_value(almanac,fn 
            {_id,%{:entity => :bomber, :position => position}} -> 
            B.Vectors.juxtapose?(position,place)
            _ -> nil
          end)
        case is_looter do
          true -> 
            fn %{}=almanac -> 
              {_key_or_nil,result} = Map.pop(almanac,bonus_id)
              result 
            end
          _no_looter -> nil
        end
      _not_bonus_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity,level) end )
  end
end

