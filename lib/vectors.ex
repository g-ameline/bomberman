defmodule B.Vectors do
  import B.Constants.Loop, only: [fps: 0]
  def to_frac({x,y,d}), do: {x,y,d}
  def to_frac({x,y}), do: {x*fps() , y*fps() , fps() }
  def to_float({x,y,d}), do: {x/d,y/d}
  def to_float({x,y}), do: {x+0.0,y+0.0}
  def place({x,y,d}), do: {div(x+div(d,2),d) , div(y+div(d,2),d)}
  def place({x,y}), do: {Kernel.round(x),Kernel.round(y)}
  def round({x,y,d}), do: {Float.round(x+0.0/d,2),Float.round(y+0.0/d,2)}
  def round({x,y}), do: {Float.round(x+0.0,2),Float.round(y+0.0,2)}

  def juxtapose?({x,y,d}=_position,{i,j}=_place) do
    cond do 
      rem(x,d) != 0 -> false
      rem(y,d) != 0 -> false
      div(x,d) != i -> false
      div(y,d) != j -> false
      true -> true
    end
  end
  def juxtapose?({x,y}=_position,{i,j}=_place), do: {x,y}=={i,j}
  def centered?({x,y,d}=_position) do
    cond do 
      rem(x,d) != 0 -> false
      rem(y,d) != 0 -> false
      true -> true
    end
  end
  def centered?({x,y}=_position) do
    place({x,y}) == {x,y}
  end
  
  def add( {a_x,a_y,d} , {b_x,b_y,d} ), do: {a_x+b_x , a_y+b_y , d}
  def add( {b_x,b_y} , {a_x,a_y,d} ), do: {a_x+(b_x*d) , a_y+(b_y*d) , d}
  def add( {a_x,a_y,d} , {b_x,b_y} ), do: {a_x+(b_x*d) , a_y+(b_y*d) , d}
  def add( {a_x,a_y} , {b_x,b_y} ), do: {a_x+b_x , a_y+b_y}
  def add( {x,y} , orientation ) when is_atom(orientation), do: add({x,y},direction(orientation))
  def add( orientation , {x,y} ) when is_atom(orientation), do: add({x,y},direction(orientation))

  def minus({x,y}), do: {-x,-y}
  def minus(v_a,v_b), do: add(v_a,minus(v_b))

  def product(k,orientation) when is_atom(orientation), do: product(k,direction(orientation))
  def product(orientation,k) when is_atom(orientation), do: product(k,direction(orientation))
  def product({_x,_y},{_xx,_yy}), do: IO.warn "probably not intented"
  def product(k,{x,y,d}), do: {x*k,y*k,d}
  def product({x,y,d},k), do: {x*k,y*k,d}
  def product({x,y},k), do: {x*k,y*k}
  def product(k,{x,y}), do: {x*k,y*k}
  def product(a,b), do: throw "WUT? #{inspect a} #{inspect b}"

  def direction(orientation) do
    case orientation do
      :still -> {0,0}
      :right -> {1,0}
      :left -> {-1,0}
      :up -> {0,-1}
      :down -> {0,1}
      unexpected -> IO.warn "wrong direction input #{inspect unexpected}"
    end
  end

  def movement(speed,orientation) when is_atom(orientation) do 
    direction = 
      direction(orientation)
    step = B.Constants.Loop.displacement()[min(13,speed)]
    (fn ({x,y},k) -> {x*k, y*k, B.Constants.Loop.fps()} end).(direction,step)
  end

  
  def dot({a_x,a_y},{b_x,b_y}), do: a_x*b_x+a_y*b_y
  def dot(orientation,{x,y}), do: dot(direction(orientation),{x,y})
  def dot({x,y},orientation), do: dot(direction(orientation),{x,y})

  def cross({a_x,a_y},{b_x,b_y}), do: a_x*b_y-a_y*b_x
  def cross(orientation,{x,y}), do: cross(direction(orientation),{x,y})
  def cross({x,y},orientation), do: cross(direction(orientation),{x,y})

  def orientations({x,y}) do
    horizontal = 
      cond do
        x == 0 -> nil
        x < 0 -> :left
        x > 0 -> :right
      end
    vertical= 
      cond do
        y == 0 -> nil
        y < 0 -> :down
        y > 0 -> :up
      end
    [horizontal,vertical]
  end

  def norm({x,y}), do: (x*x+y*y)**0.5
  def distance(a,b), do: minus(b,a) |> length()

end

