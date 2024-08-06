defmodule B.Entities do
  def new_bomber(pid,position) do
  %{:entity => :bomber,
    :id => pid,
    :position => position,
    :lives => B.Constants.Bombers.lives(),
    :range => B.Constants.Bombers.range(),
    :speed => B.Constants.Bombers.speed(),
    :bombs => B.Constants.Bombers.bombs(),
    :grace => 0,
    :orientation => :still,
    :bombing => false,
    :start=> false }
  end
  def new_bomb(bomber_id,range,position) do
  %{:entity => :bomb,
    :bomber => bomber_id,
    :id => B.Functions.uuid(),
    :position => B.Vectors.place(position),
    :range => range,
    :expiry => B.Constants.Bombs.expiry() }
  end
  def new_bomb(
    %{:entity => :bomber,:position => position, 
    :id => bomber_id, :range => range}=_bomber) do
    new_bomb(bomber_id,range,position)
  end
  def new_flame(orientation,range,position) do
  %{:entity => :flame,
    :id => B.Functions.uuid(),
    :position => position,
    :range => range,
    :expiry => B.Constants.Flames.expiry(),
    :incubation => B.Constants.Flames.incubation(),
    :orientation => orientation }
  end
  def new_bonus(position) do
  %{:entity => :bonus,
    :id => B.Functions.uuid(),
    :bonus => Enum.random(B.Constants.Bonus.types()),
    :position => position }
  end
  def new_block(position) do
  %{:entity => :block,
    :id => B.Functions.uuid(),
    :position => position }
  end
  def new_wall(position) do
  %{:entity => :wall,
    :id => B.Functions.uuid(),
    :position => position }
  end
end  
