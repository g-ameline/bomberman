# ############### BOMBS ############### 
defmodule B.Mechanics.Bomb do
end
defmodule B.Mechanics.Bomb.Put do
# callback to map over each level's element to create an updater function
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber, :bombing => false}-> 
        nil
      %{:entity => :bomber, :bombs => 0}-> 
        nil
      %{:entity => :bomber, :id => _, 
        :position => _, :bombing => true,
        :range => _, :bombs => _
      }=old_bomber-> 
          # IO.puts "      there is an order to put bomb"
          new_bomb = B.Entities.new_bomb(old_bomber)
          fn 
            %{}=almanac -> 
              B.Functions.deep_graft(almanac, %{new_bomb[:id] => new_bomb}) 
          end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(almanac) do
    B.Mechanics.level_updaters_from_fore_updater(almanac,fn entity-> fore_updater(entity) end )
  end
end
defmodule B.Mechanics.Bomb.Decay do
# callback to map over each level's element to create an updater function
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomb, :id => bomb_id, :expiry => _expiry}-> 
        # IO.puts "should EXPIRE a bit #{inspect _expiry}"
        fn 
          %{^bomb_id=>_}=almanac -> 
            # IO.puts "  EXPIRE"
            update_in(almanac,[bomb_id,:expiry],fn expiry -> (expiry - 1) end) 
          map_without_the_bomb -> map_without_the_bomb 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(almanac) do
    B.Mechanics.level_updaters_from_fore_updater(almanac,fn entity-> fore_updater(entity) end )
  end
end
defmodule B.Mechanics.Bomb.Trigger do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomb, :id => bomb_id, :expiry => 0}-> 
        fn 
          %{}=almanac -> 
            {_key_or_nil,result} = pop_in(almanac,[bomb_id])
            result 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(almanac) do
    B.Mechanics.level_updaters_from_fore_updater(almanac,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Bomb.Blown do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bomb, :position => place, :id => bomb_id}-> 
        bomb_overlap_flame? = Enum.any?(almanac, fn 
          {_id,%{:position => ^place, :entity => :flame}} -> 
            true
          {_id,_not_a_flame}=_element -> 
            false 
        end)
        case bomb_overlap_flame? do
          false -> nil
          true -> 
            fn 
              %{}=almanac -> 
                {_key_or_nil,result} = Map.pop(almanac,bomb_id)
                result 
            end
        end
      _not_a_bomb -> nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity,level) end )
  end
end

