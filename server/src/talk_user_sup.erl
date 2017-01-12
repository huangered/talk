-module(talk_user_sup).
-behaviour(supervisor).

-export([start_link/0, start_child/1]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_child({Id, Name}) ->
    supervisor:start_child(?MODULE, [{Id, Name}]).

init([]) ->
    User = {talk_user, {talk_user, start_link, []},
               temporary, brutal_kill, worker, [talk_user]},
    Children = [User],
    RestartStrategy = {simple_one_for_one, 0, 1},
    {ok, {RestartStrategy, Children}}.