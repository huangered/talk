-module(server_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	TalkServer = {core,  {core, start_link, []},  permanent, brutal_kill, worker, [core]},
	TcpServerSup = {tcpserver_sup, {tcpserver_sup, start_link, []}, permanent, brutal_kill, supervisor, [tcpserver_sup]},
	MsgPoolServer = {message_pool, {message_pool, start_link, []}, permanent, brutal_kill, worker, [message_pool]},
	Procs = [TalkServer, MsgPoolServer, TcpServerSup],
	{ok, {{one_for_one, 1, 5}, Procs}}.
