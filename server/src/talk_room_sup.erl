-module(talk_room_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Room = {talk_room, {talk_room, start_link, []},
               temporary, brutal_kill, worker, [talk_room]},
    Children = [Room],
    RestartStrategy = {simple_one_for_one, 0, 1},
    {ok, {RestartStrategy, Children}}.