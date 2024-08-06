defmodule B.Mechanics.Block do
end
defmodule B.Mechanics.Block.Consume do
# callback to map over each level's element to create an updater function
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :block, :id => block_id, :position => place}-> 
        overlap_something? = Enum.any?(almanac, fn 
          {_id,%{:position => ^place, :entity => entity}=_stuff} -> 
            entity == :flame 
          {_id,_not_an_entity}=_element -> 
            false 
        end)
        case overlap_something? do
          false -> nil
          true -> 
            fn 
              %{}=almanac -> 
                {_key_or_nil,result} = pop_in(almanac,[block_id])
                result 
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
