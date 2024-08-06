defmodule B.Application do
  alias B.Constants.Connection, as: C
  use Application
  @impl true
  def start(_type, _args) do
    children = [
      ### presentation ###
      _pages_server = {Bandit, plug: B.Presentation.Page_server, scheme: :http, port: C.pages_port() },
      ### juncture ###
      _chat_server = {Bandit, plug: B.Juncture.Chat.Server, scheme: :http, port: C.ws_chat_port()},
      _gamepad_server = {Bandit, plug: B.Juncture.Gamepad.Router, scheme: :http, port: C.ws_gamepad_port()},
      _game_server = {Bandit, plug: B.Juncture.Game.Router, scheme: :http, port: C.ws_game_port()},
      ### logic ###
      _chat_room = {B.Logic.Chat.Room, nil},
      _lobby = {B.Logic.Lobby, []},
      _game_issuer = {B.Logic.Game.Issuer,%{}}
    ]

  ########## CHAT ###########
    
    options =  [strategy: :one_for_one]
    {:ok, _supervisor_pid} = Supervisor.start_link(children,options)

  end
end

