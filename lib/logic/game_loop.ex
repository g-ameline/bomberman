defmodule B.Logic.Game.Loop do

  def start(players) do
    init_game_state = B.Level.level_from_players(players)
    init_game_state = Map.put(init_game_state , :init, true)
    spawn fn -> loop(init_game_state) end
  end
  def loop(previous_almanac) do
    previous_almanac = 
      case Map.has_key?(previous_almanac, :init) do
        true ->
          B.Logic.Game.Issuer.update(self(),previous_almanac)
          count_down(B.Constants.Loop.wait())
          Map.delete(previous_almanac,:init)
        false -> previous_almanac
      end
    ############# CALCUL START ############
    loop_start = B.Functions.now()
    ############# LOGIC UPDATES ############
    ####### BOMBER UPDATERS ######
    bomber_updaters = B.Mechanics.Bomber.Continue.updaters(previous_almanac)
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Stop.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Orient.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Bombing.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Drop.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Reload.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Return.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Enhance.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Grace.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Disgrace.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Burn.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Remove.updaters(previous_almanac))
    bomber_updaters = Stream.concat(bomber_updaters, B.Mechanics.Bomber.Notice.updaters(previous_almanac))

    ####### BOMB UPDATERS ######
    bomb_updaters = B.Mechanics.Bomb.Put.updaters(previous_almanac)
    bomb_updaters = Stream.concat(bomb_updaters, B.Mechanics.Bomb.Decay.updaters(previous_almanac))
    bomb_updaters = Stream.concat(bomb_updaters, B.Mechanics.Bomb.Blown.updaters(previous_almanac))
    bomb_updaters = Stream.concat(bomb_updaters, B.Mechanics.Bomb.Trigger.updaters(previous_almanac))

    ####### FLAME UPDATERS ######
    flame_updaters = B.Mechanics.Flame.Burst.updaters(previous_almanac)
    flame_updaters = Stream.concat(flame_updaters, B.Mechanics.Flame.Ignite.updaters(previous_almanac))
    flame_updaters = Stream.concat(flame_updaters, B.Mechanics.Flame.Incubate.updaters(previous_almanac))
    flame_updaters = Stream.concat(flame_updaters, B.Mechanics.Flame.Spread.updaters(previous_almanac))
    flame_updaters = Stream.concat(flame_updaters, B.Mechanics.Flame.Decay.updaters(previous_almanac))
    flame_updaters = Stream.concat(flame_updaters, B.Mechanics.Flame.Remove.updaters(previous_almanac))
    flame_updaters = Stream.concat(flame_updaters, B.Mechanics.Flame.Consume.updaters(previous_almanac))
    
    ####### BLOCK UPDATERS ######
    block_updaters = B.Mechanics.Block.Consume.updaters(previous_almanac)

    ####### BONUS UPDATERS ######
    bonus_updaters = B.Mechanics.Bonus.Drop.updaters(previous_almanac)
    bonus_updaters = Stream.concat(bonus_updaters, B.Mechanics.Bonus.Remove.updaters(previous_almanac))

    ############# SPLIT LEVEL BY ENTITY TYPES ############
    split = B.Level.split_by_entities(previous_almanac)
    ############# APPLY ALL UPDATES ############
    updating_bombers = Task.async(fn -> B.Mechanics.apply_updaters(split[:bombers],bomber_updaters) end)
    updating_flames = Task.async(fn -> B.Mechanics.apply_updaters(split[:flames],flame_updaters) end)
    updating_bombs = Task.async(fn -> B.Mechanics.apply_updaters(split[:bombs],bomb_updaters) end)
    updating_blocks = Task.async(fn -> B.Mechanics.apply_updaters(split[:blocks],block_updaters) end)
    updating_bonuses = Task.async(fn -> B.Mechanics.apply_updaters(split[:bonuses],bonus_updaters) end)
    updated_almanac =
      split[:rest]
      |> Map.merge(Task.await(updating_bombers) )
      |> Map.merge(Task.await(updating_flames) )
      |> Map.merge(Task.await(updating_bombs) )
      |> Map.merge(Task.await(updating_blocks) ) 
      |> Map.merge(Task.await(updating_bonuses) ) 
    ############# SHARE GAME STATE ############
    B.Logic.Game.Issuer.update(self(),updated_almanac )
    ############# LOOP DURATION REGULATION ############
    end_calculation = B.Functions.now()
    duration = end_calculation - loop_start
    advance = max(0,B.Constants.Loop.frame_duration() - duration)
    Process.sleep(trunc advance/1_000_000)
    case B.Mechanics.is_game_over(updated_almanac) do
      true -> 
        B.Logic.Game.Issuer.remove(self(),updated_almanac)
      false -> 
        loop(updated_almanac )
    end
  end

  def count_down(waiting_time) do
    B.Logic.Chat.Room.spread("game will start, be sure to have a game window opened and click on PID when ready")     
    f = fn 
      0, _recurse -> 
        B.Logic.Chat.Room.spread("NOW !")
      ms, recurse ->  
        Process.sleep(1000)
        B.Logic.Chat.Room.spread("#{ms/1000} seconds til game start")
        recurse.(ms- 1000, recurse)
      end
    f.(waiting_time,f)
  end

end
