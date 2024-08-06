# Bomberman

This is a *simple* bomberman clone.
It runs on a server written in Elixir.
The front end is written with the "gost framework" our framework. 
This was done as part of my IT training with mandatory specifications thus, 
some features could not be implemented in the most user-friendly way

## start the server

if you have elixir installed :
`mix deps.get`
`mix`
if not, run :
`bash run_container.sh`

## play the game in a browser

### initialization
open your browser and go to:
http://localhost:1111/
open the chat by typing a name,
chat also display server messages
### controls
spawn gamepad by clicking on the desired keyboard pattern
For the wasd bindings :
 - Q is *start* command, to tell the server that you are to start playing
 - WASD are the *directions* commands
 - E is dropping a *bomb*
Otherwise, just over the key to see what key(code) correspond to the command
You can also press any keyboard key while hovering to change it. 
> for testing you will probably want to spawn a "WASD-QE pad" and a arrows "right_shift... pad"
 and then press *q* and *enter*  ***one time*** and wait for the game to start
### start a game
After the controller(s) appeared, at least 2 players/gamepads need to press *start* ***one time***.
If multiple players are ready, a game will soon start with those players.
When a new pid pop on the game display, click on it to open the game.
### gameplay
Each bomber (colored discs) can move orthogonality and and drop a bomb.
The goal is to be last man standing and caughting other players in the   
blast of your bombs or their own bombs helps a lots.
You got 3 lives, you can take 2 blasts before being game over.
You start with 1 bomb.
Level is composed of wall(black squares) and blocks(grey squares), 
only the former can be destroyed by bomb blast.
Doing so, a bonus mght drop, juicing up speed, bombs quantity or blast range. 

## stop the server
`Ctrl-c`
or if containerized :
`bash stop_container.sh`
`bash clean_container.sh`

## disclaimer

> When the user opens the game, they should be presented to a page where they should enter a nickname to differentiate users. After selecting a nickname the user should be presented to a waiting page with a player counter that ends at 4. Once a user joins, the player counter will increment by 1.

We infringed the rule a lttle here,
One design decision being it should be playable to multiple player locally on the same browser tab,  
we decorrelated the chat from the players (one player != one chat user)  
so you can have on the same window 2 players and 1 chat window.
this means the name used to identify *chat user* is not related to *player*.  
To identify players we used another "trick" , each virtal gamepad have an id (pid)
this id is linked to each player, and front end match the color of each pad with the each player's color  
(sincere apologies for color-blind people) 

> If there are more than 2 players in the counter and it does not reach 4 players before 20 seconds, a 10 second timer starts, to players get ready to start the game.
If there are 4 players in the counter before 20 seconds, the 10 seconds timer starts and the game starts.

Becasue everyone's time here is precious the counter have been reduced from 20 and 10 seconds to ~ 10 and 5 seconds.
I believe you will not be too upset about it.

The game's aesthetic is rather minimalist, or just ugly,
same for the UI.
There is no test files.

## details

the server's *logic* can host an unlimited number of games
unfortunately it starts to slow down when more than one game or a bigger map  
is running on my machine (mid range power laptop).
Despite (or because) of high use of concurrency and parallelism in elixir game's loop.
There is plenty of room for optimization though. 

