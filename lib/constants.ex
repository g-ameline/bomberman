defmodule B.Constants do
end
defmodule B.Constants.Folder do
  def path_to_static, do: "./lib/presentation/"
end
defmodule B.Constants.Lobby do
  def wait, do: 4000 #ms
end
defmodule B.Constants.Connection do
  ### where to get fron end ~ webserver ~ presentation
  def pages_port(), do: 1111
  def main_path(), do: "main"
  def chat_path(), do: "chat"
  def gamepad_path(), do: "gamepad"
  def game_path(), do: "game"
  ### ws port for each communication channels
  def ws_protocol(), do: "ws"
  def ws_chat_port(), do: 3333
  def ws_chat_path(), do: "chat"
  def ws_gamepad_port(), do: 5555
  def ws_gamepad_path(), do: "gamepad"
  def ws_game_port(), do: 7777
  def ws_game_path(), do: "game"
end
defmodule B.Constants.Loop do
  def wait, do: 4000 #ms
  def displacement() do 
    %{1=>2, 2=>3, 3=>4, 4=>5, 5=>6, 6=>8, 7=>10, 8=>12, 9=>15, 10=>20, 11=>24,12=>30,13=>40} # as a 1/120 frac
    # %{1=>2/120, 2=>3/120, 3=>4/120, 4=>5/120, 5=>6/120, 6=>8/120, 7=>10/120, 8=>12/120}
    # divisors of 120 :  
    #   1 | 2 | 3 | 4 | 5 | 6 | 8  | 10 | 12  | 15 | 20 | 24 | 30 | 40 | 60 | 120  step length unit
    #  120|60 |40 |30 |24 |20 |15  | 12 | 10  | 8  | 6  | 5  | 4  | 3  | 2  | 1    frames to move
    #  1  |.5 |.33|.24|.2 |.15|.125| .1 |.0833|.067|.05 |.042|.033|.024|.015|.0083 seconds to move
  end
  def fps(), do: 120 # Hz
  def frame_duration(), do: 1/fps() * 1.0e9 # ns
  # 1s is 1_000_000_000 | 0.1s 100_000_000 | 60 fps is 15_000_000 | 120 fps is 7_500_000
end
defmodule B.Constants.Commands do
  # inputs and commands atoms
  def orientations, do: [:still, :left, :right, :up, :down]
  _ = :bomb # input
  _ = :bombing  # state/command
  _ = :start  # state/command
end
defmodule B.Constants.Bombers do
  # bombers #
  def lives(), do: 3
  def bombs(), do: 1
  def range(), do: 0
  def speed(), do: 1
  def grace(), do: 100
end
defmodule B.Constants.Bombs do
  def expiry() , do: 200
end
defmodule B.Constants.Bonus do
  def drop_chance(), do: 0.9 
  def types() , do: [:speed,:range,:bombs]
end
defmodule B.Constants.Flames do
  def expiry, do: 30
  def incubation, do: 10
end
defmodule B.Constants.Blocks do
  def breadth, do: 1
  def shape, do: :square
end
defmodule B.Constants.Walls do
  def breadth, do: 1
  def shape, do: :square
end
defmodule B.Constants.Level do
  def width, do: 9
  def height, do: 6
end
