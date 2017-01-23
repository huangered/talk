-module(server_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  TalkServer = {talk_core,  {talk_core, start_link, []},  permanent, brutal_kill, worker, [core]},
  TcpServerSup = {tcpserver_sup, {tcpserver_sup, start_link, []}, permanent, brutal_kill, supervisor, [tcpserver_sup]},
  TalkUserSup = {talk_user_sup,{talk_user_sup, start_link,[]},permanent, brutal_kill, supervisor,[talk_user_sup]},
  RoomSup = {talk_room_sup, {talk_room_sup, start_link,[]}, permanent, brutal_kill, supervisor, [talk_room_sup]}, 
  Procs = [TalkServer, TcpServerSup, TalkUserSup, RoomSup],
  {ok, {{one_for_one, 1, 5}, Procs}}.
