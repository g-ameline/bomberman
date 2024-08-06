# bomberman code structure

 lib/
├──  presentation/
├──  juncture/
├──  logic/
│
├──  mechanics/
├──  application.ex
├──  b_nvm.ex
├──  constants.ex
├──  entities.ex
├──  functions.ex
├──  level.ex
└──  vectors.ex ./

presentation - juncture - logic 
are the three layers of the applciations
the rest is mostly helpers functions,
mechanics module being dedicated to game's loop core mechanics.

Inside presentation, juncture and logic modules are further  
differentiated by function :
 chat - gamepad - game(~game display)
those three do not share any data until reaching the logical layer

**_nvm.ex modules are empty upper level module* 

## presentation 

Front end part, route request and serve html+js pages to client

## junture

Take care of any communication bewtween client and server;
those communications are websocket only.
There is no state saved there

## logic

This where state lie in, as well as any logic dependig on it. 

## application

The entry point for the app to start and set up process supervision structure.

## mechanics

any function needed for the gameplay of the bomberman game  
mostly used inside the game's loop in the logic tier

## others

- constants: genreal value that are used in various other places
that sometimes require to be tuned/tweaked to adjust the gameplay (fps, bomb's countdown ...)
- functions: similar things genreal functions like getting time now in ns /ms
- vectors: basic vector operations (adding, scalar product ...)
- entities:  basic functions specific to each game's entity, ex : data structure of bomb
- level: same thing for level definition, mostly used for generating level before game's loop starts

