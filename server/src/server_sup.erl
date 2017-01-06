-module(server_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	Procs = [{core,  {core, start_link, []},  permanent, brutal_kill, worker, [core]},
	         {entry, {entry, start_link, [12345]}, permanent, brutal_kill, worker, [entry]}],
	{ok, {{one_for_one, 1, 5}, Procs}}.
