defmodule Loop.Helpers do
  alias Constants.grace_span
### general 
  def direction, do: {:still, :left, :right, :up, :down} 
  def nought(whatever), do: :naught 
  def untouch(whatever), do: whatever 
### bomber stuff
  def burn(entity = %{:lives => n}), do: %{entity | :lives => n-1} 
  def disgrace(entity = %{:grace => n}), do: %{entity | :grace => n-1} 
  def up_speed(entity = %{:speed => n}), do: %{entity | :speed => n+1} 
  def up_flame(entity = %{:range => n}), do: %{entity | :range => n+1} 
  def up_bombs(entity = %{:bombs => n}), do: %{entity | :bombs => n+1} 
### block and flames
  def juxtapose?( A={A_x,A_y}, B={B_x,B_y}), do: A == B
  def juxtapose?( %{:position => A}, %{:position => B}), do: juxtapose?(A,B)
  def consume(block,flame) do
    case juxtapos?(block,flame) do
      true -> :naught
      false -> block 
    end
  end
### bombs and flames
  def decay(entity = %{:span => n}), do: %{entity | :span => n-1} 
### spawning   flame & bonus
  def explode(bomb = %{
  :position => spot, 
  :range => range,
  :countdown => countdown,
  }) do
    new_flames = Enum.map(orientations() ,fn orientiation ->
      %{ 
        :position => plus(spot,direction(orientation)), 
        :orientation => orientation, 
        :lingering => linering(), 
        :extent => range,
        :incubation => incubation()
      } 
    end)
    fn flames -> MapSet.merge(flames,new_flames)
  end
  def spread_flame(flame = %{
  :position => spot, 
  :orientation => orientation, 
  :lingering => lingering, 
  :extent => extent,
  :incubation => incubation
  }) do
    if extent < 1 do
      IO.warn("should not happen")
      :naught
    end
    new_flame = %{entity | 
      :position => plus(spot,direction(orientation)), 
      :orientation => orientation, 
      :lingering => linering(), 
      :extent => extent - 1,
      :incubation => incubation()
    } 
  end
  ## bonus stuff
  def drop_bonus(entity = %{:position => spot}) do
    case create_bonus() do
      :naught -> :naught 
      bonus -> %{:position => spot, :bonus => bonus}
    end
  end
  def create_bonus(chance\\0.2) do
    if rand.uniform() > chance do :naught end
    case rand.uniform() do
      x when x < 1/3 -> 
        :flame
      x when  1/3 < x && x < 2/3 -> 
        :bombs
      _ -> 
        :speed
    end
  end   
  def burn(bombers,flames) do
    Enum.map(bombers, fn bomber ->
      if Enum.any(flames, fn flame -> overlap?(flame,bomber) end) do
        new_lives = bomber[:lives] - 1
        new_grace = grace_span
        Map.merge(bomber ,%{:grace => new_grace,:lives => new_lives})
      else
        bomber
      end
    end )
  end
  def disgrace(bombers) do
    Enum.map(bombers, fn bomber -> 
        grace = bomber[:grace] 
        if grace > 0 do
          new_grace = bomber[:grace] -1 
          Map.merge(bomber ,%{:grace => new_grace})
        else
          bomber
        end
    end )
  end
  def reap(bombers) do
    Enum.filter(bombers, fn bomber -> bomber[:lives] < 0 end) 
  end
  # if bombing command AND 1+ bomb : remove one bomb
  # if no bomb remove the 
  def unload(bombers) do
    new_bombs = Enum.map(bombers, fn bomber -> 
      if bomber[:bombing] && bomber[:bombs] > 0 do 
        map.merge(bomber,%{:bombing => false, :bombs => bomber[:bombs]-1})
      else
        bomber
      end
    end)
  end
  def bombing(bombers,bombs) do # if bombing command drop a bomb at the middle square
    new_bombs = Enum.map(bombers, fn bomber -> 
      if bomber[:bombing] do 
        %{:position => midst(bomber), :span => bomb_span(),
          :range => bomber[:range],:bomber => bomber[:pid] }
      end
    end) 
    Map.merge(bombs,new_bombs)
  end
  def move(bombers) do 
    Enum.map(bombers, fn bomber -> 
      case bomber[:direction] do
        :still -> bomber 
        direction -> 
          Geo.mult(bomber[:direction], bomber[:speed]) # a set of movement vectors
        _ -> IO.warn("man, what is that : "++inspect direction) 
      end
    end) 
  end
  def collision(bombers) do 
    Enum.map(bombers, fn bomber -> 
      case bomber[:direction] do
        :still -> bomber 
        direction -> 
          Geo.mult(bomber[:direction], bomber[:speed]) # a set of movement vectors
        _ -> IO.warn("man, what is that : "++inspect direction) 
      end
    end) 
  end
end
defmodule Geo do
  def overlap?(thingie,thingo,threshold) do
    if distance(thingie,thingo) < threshold do
      true
    else 
      false
    end
  end
  def length({A_x,A_y} ,{B_y,B_y} ) do
    :math.sqrt( (A_x-B_y)**2 + (A_y-B_y)**2 )
  end
  def length(%{:position => {A_x,A_y}},%{:position => {B_y,B_y}}) do 
    length({A_x,A_y} ,{B_y,B_y})
  end
  def plus({A_x,A_y},{B_y,B_y}) do
    {A_x+B_y,A_y+B_y}
  end
  def plus(%{:position=>{A_x,B_y}},%{:position => {B_y,B_y}}) do
   add({A_x,A_y},{B_y,B_y})
  end
  def minus({A_x,A_y}) do
    {-A_x,-A_y}
  end
  def minus({A_x,A_y},{B_y,B_y}) do
    {A_x-B_y,A_y-B_y}
  end
  def midst({x,y}) do
    {trunc(x)+0.5,trunc(y)+0.5} # middle of squares are {i.5,j.5}
  end
  def midst(%{:position => {x,y}}), do: midst {trunc(x)+0.5,trunc(y)+0.5}
  def direction_to_vector(direction) do
    case direction do
      :left -> {-1,0}
      :right -> {+1,0}
      :down -> {0,+1}
      :up -> {0,-1}
      :still -> {0,0}
      _ -> IO.warn("what the heck dude ? "++direction)
    end
  end
  def mult({x,y},k) do
    {x*k,y*k} 
  end
  def mult(%{:position => {x,y}},k), do: mult({x,y},k)
  # vector >AB> cross vector >CD> ?
  def slide({{A_x,A_y},{B_y,B_y}},{{x_c,y_c},{x_d,y_d}}) do

    {x*k,y*k}
  end
  def cross({A_x,A_y},{B_y,B_y}) do
    A_x*B_y - B_y*A_y
  end
  def dot({A_x,A_y},{B_y,B_y}) do
    A_x*B_y + B_y*B_y
  end
  def clockwise?(Vob,Voc) do # >AB> to >CD>
    cross(Vab,Vcd)>0
  end
  def between?(Voa,Vom,Voz) do # >Vom> between Voa and Vob 
    clockwise?(Voa,Vom) == clockwise?(Vom,Voz)
  end
  # def intersection(O,Z,C,D) do # >OZ> instersect >CD> 
  def intersection_point({{O_x,O_y},{Z_x,Z_y}},{{C_x,C_y},{D_x,D_y}}) do # >OZ> instersect >CD> 
    # from wikipedia
    const denominator = ( (O_x - Z_x)*(C_y-D_y)-(O_y-Z_y)*(C_x-D_x) ) 
    if denominator == 0, do: {:false,_}
    const t = ((O_x - C_x)*(C_y-D_y)-(O_y-C_y)*(C_x-D_x)) / denominator
    const u = ((O_x - C_x)*(O_y-Z_y)-(O_y-C_y)*(O_x-Z_x)) / denominator
    if t< 0 || 1 < t || u < 0 || 1 < u, do: {:false,_}
    OZ = minus(Z,O)
    # I is intersection point on OZ and BC
    OI = plus(a,mult(OZ,t))
    return {:true,OI}
  end
  # def slide(%{:position => {x,y}},k) do
  #   {x*k,y*k}
  # end
end
