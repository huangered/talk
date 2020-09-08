-module(tcpserver_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, [12345]).

init([Port]) ->
	Procs = [{tcpserver,  {tcpserver, start_link, [Port]},  permanent, brutal_kill, worker, [tcpserver]}],
	{ok, {{one_for_one, 1, 5}, Procs}}.
