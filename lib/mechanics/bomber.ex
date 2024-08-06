
# ############### BOMBER ############### 
defmodule B.Mechanics.Bomber do 
end
# ############ commands ############
defmodule B.Mechanics.Bomber.Orient do
  alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level,almanac) do
    case value do
      %{:entity => :bomber, :id => player_pid, :speed => speed,
        :position => position, :orientation => :still
      }=_old_bomber-> 
        case V.centered?(position) do
          false -> nil
          true ->
            send(player_pid, {:orientation,self()})
            receive do 
              {:orientation, :still} ->
                nil
              {:orientation, new_orientation } ->
                case obstructed?(position,new_orientation,almanac) do 
                true -> nil
                false ->  
                  movement = B.Vectors.movement(speed,new_orientation)
                  fn 
                    %{^player_pid => _bomber}=almanac ->
                      put_in(almanac, [player_pid,:orientation], new_orientation)
                      |> update_in([player_pid,:position], fn position-> V.add(position, movement) end) 
                    map_without_bomber -> map_without_bomber 
                  end
              end
              unexpected -> 
                IO.warn "something wrong #{inspect unexpected}"
                nil 
            end
        end  
      _not_bomber_entity -> 
        nil
    end
  end
  def obstructed?(position,orientation,%{:level=>:almanac}=almanac) do
    place = V.place(position)
    next_place = V.add(place,V.direction(orientation)) 
    Enum.any?(almanac, fn 
      {_id,%{:position => ^next_place,:entity => entity}=_stuff} -> 
        entity in [:block, :wall, :bomb] 
      {_id,_not_an_entity}=_element -> 
        false 
    end)
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity,level) end )
  end
end

defmodule B.Mechanics.Bomber.Bombing do
  alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber, :id => player_pid,:bombing => old_bombing 
      }=_old_bomber-> 
        send(player_pid, {:bombing,self()})
        spawn( fn -> send(player_pid, {:reset_bombing}) end )
        receive do 
          {:bombing, new_bombing } when new_bombing == old_bombing ->
            nil
          {:bombing, new_bombing } ->
            fn 
              %{^player_pid => _bomber}=almanac ->
                B.Functions.deep_graft(almanac, %{player_pid => %{:bombing => new_bombing}}) 
              map_without_bomber -> map_without_bomber 
            end
          _other-> 
            nil 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end
# ############ actions ############
defmodule B.Mechanics.Bomber.Continue do
  alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber,:orientation => :still}-> 
        nil
      %{:entity => :bomber,
        :id => player_pid,
        :orientation => orientation,
        :position => position,
        :speed => speed
      }-> 
        case V.centered?(position) do
          true -> nil
          false -> 
            movement = B.Vectors.movement(speed,orientation)
            fn 
              %{^player_pid => _bomber}=almanac ->
               update_in(almanac,[player_pid,:position] , fn position -> V.add(position, movement) end) 
              map_without_bomber -> map_without_bomber
            end
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Bomber.Stop do
  alias B.Vectors, as: V
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber,:orientation => :still}-> 
        nil
      %{:entity => :bomber,
        :id => player_pid,
        :position => position
      }-> 
        case V.centered?(position) do
          false -> nil
          true -> 
            fn 
              %{^player_pid => _bomber}=almanac ->
               put_in(almanac,[player_pid,:orientation], :still) 
              map_without_bomber -> map_without_bomber
            end
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Bomber.Drop do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber, :bombing => false}-> 
        nil
      %{:entity => :bomber, :bombs => 0 }=_old_bomber-> 
        nil
      %{:entity => :bomber, :id => player_pid, 
        :bombing => true, :bombs => _bombs
      }=_old_bomber-> 
        fn 
          %{^player_pid => _bomber}=almanac ->
            update_in(almanac,[player_pid,:bombs],fn n_bombs -> (n_bombs - 1) end) 
          map_without_bomber -> map_without_bomber 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Bomber.Burn do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bomber, :id => player_pid, 
        :position => position, :grace => 0,
      } -> 
        place = B.Vectors.place(position)
        overlap_something? = Enum.any?(almanac, fn 
          {_id, %{:position => ^place, :entity => :flame}} -> 
            true
          {_id, _not_a_flame_or_somewhere_else}=_element -> 
            false 
        end)
        case overlap_something? do
          false -> nil
          true -> 
            fn 
              %{^player_pid => _bomber}=almanac ->
                update_in(almanac,[player_pid,:lives],fn lives -> (lives - 1) end) 
              map_without_bomber -> map_without_bomber 
            end
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity,level) end )
  end
end

defmodule B.Mechanics.Bomber.Enhance do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bomber, :id => player_pid, :position => position
      } -> 
        case B.Vectors.centered?(position) do 
          false -> nil
          true -> 
            place = B.Vectors.place(position)
            attribute = 
              Enum.find_value(almanac,nil,fn 
                {_id,%{:entity => :bonus, :position => ^place, :bonus => attribute}} -> attribute
                _ -> nil
              end)
            case attribute do
              nil -> nil
              attribute -> 
                fn 
                  %{^player_pid => _bomber}=almanac ->
                    update_in(almanac,[player_pid,attribute],fn attr-> (attr+ 1) end) 
                  map_without_bomber -> map_without_bomber 
                end
            end
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity,level) end )
  end
end

defmodule B.Mechanics.Bomber.Grace do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bomber, :id => player_pid, 
        :position => position, :grace => 0,
      } -> 
        place = B.Vectors.place(position)
        overlap_something? = Enum.any?(almanac, fn 
          {_id, %{:position => ^place, :entity => :flame}} -> 
            true
          {_id, _not_a_flame_or_somewhere_else}=_element -> 
            false 
        end)
        case overlap_something? do
          false -> nil
          true -> 
            fn 
              %{^player_pid => %{:grace => 0}}=almanac ->
                update_in(almanac,[player_pid,:grace],fn _grace -> B.Constants.Bombers.grace() end) 
              map_without_bomber -> map_without_bomber 
            end
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity,level) end )
  end
end


defmodule B.Mechanics.Bomber.Disgrace do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber, :grace => 0}->
        nil 
      %{:entity => :bomber, :grace => _some_grace, :id => player_pid}->
        fn 
          %{^player_pid => _bomber}=almanac ->
            update_in(almanac,[player_pid,:grace],fn grace -> (grace - 1) end) 
          map_without_bomber -> map_without_bomber 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Bomber.Reload do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomb, :expiry => 0, :bomber => player_pid}-> 
        fn 
          %{^player_pid => _bomber}=almanac ->
            update_in(almanac,[player_pid,:bombs],fn n_bombs -> (n_bombs + 1) end) 
          map_without_bomber -> map_without_bomber 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end
defmodule B.Mechanics.Bomber.Return do
  def fore_updater({_key,value}=_element_from_level,%{:level => :almanac}=almanac) do
    case value do
      %{:entity => :bomb, :position => place, :bomber => player_pid}-> 
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
              %{^player_pid => _bomber}=almanac ->
                update_in(almanac,[player_pid,:bombs],fn n_bombs -> (n_bombs + 1) end) 
              map_without_bomber -> map_without_bomber 
            end
        end
      _not_a_bomb -> nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity -> fore_updater(entity,level) end )
  end
end

defmodule B.Mechanics.Bomber.Remove do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber, :id => player_pid, :lives => 0}-> 
        fn 
          %{}=almanac -> 
            {_key_or_nil,result} = pop_in(almanac,[player_pid])
            result 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

defmodule B.Mechanics.Bomber.Notice do
  def fore_updater({_key,value}=_element_from_level) do
    case value do
      %{:entity => :bomber, :id => player_pid, :lives => 0}-> 
        fn 
          %{}=almanac -> 
            send(player_pid,:lost)
            almanac 
        end
      _not_bomber_entity -> 
        nil
    end
  end
  def updaters(level) do
    B.Mechanics.level_updaters_from_fore_updater(level,fn entity-> fore_updater(entity) end )
  end
end

