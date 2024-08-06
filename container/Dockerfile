FROM elixir:latest
# bomberman/
# └ lib/
#     ├ presentation/...
#     ├ juncture/...
#     └ logic/...
# 
ADD ./archive/ ./archive/  
ADD ./lib/ ./lib/  
ADD ./test/ ./test/  
ADD ./mix.exs ./mix.exs  
ADD ./mix.lock ./mix.lock  
RUN ls -lha
# page server's ws port
EXPOSE 1111
# chat server's ws port
EXPOSE 3333
# gamepad server's ws port
EXPOSE 5555 
# game display server's ws port
EXPOSE 7777
RUN mix deps.get
RUN mix compile
CMD ["mix"]

