-module(talk_room_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  io:format("start room~n",[]),
  Room = {talk_room, {talk_room, start_link, []},
          permanent, brutal_kill, worker, [talk_room]},
  Children = [Room],
  RestartStrategy = {one_for_one, 1, 5},
  {ok, {RestartStrategy, Children}}.
