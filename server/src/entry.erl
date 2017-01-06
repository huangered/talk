%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(entry).
-behaviour(gen_server).

%% api
-export([start_link/1, start/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
                port=0   %% server port
               }).

%% api
start_link(Port) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).		 

start() ->
  gen_server:cast(?MODULE, start).

%% callback

init([Port]) ->
  {ok, #state{port = Port}}.

handle_call(_Req, _From, State) ->
    {reply, ignored, State}.

handle_cast(start, State = #state{port = Port}) ->
    io:format("Port from state ~p~n", [Port]),
    server(Port),
    {noreply, State}.

handle_info(Msg, State = #state{port = Port}) ->
    case Msg of
      port -> io:format("Get port ~p~n", [ Port ]);
      _  -> io:format("unknown~n")
    end,
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% private api
server(Port) ->
  io:format("Start..."),
  {ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false},{reuseaddr, true}]),
  accept(Listen).

accept(Listen) ->
  {ok, Sock} = gen_tcp:accept(Listen),
  spawn(fun() -> loop(Sock) end),
  accept(Listen).

%close(Sock) ->
%  ok = gen_tcp:close(Sock).

loop(Sock) -> 
  {ok, {Address, Port}} = inet:peername(Sock),  
  io:format("Remote socket: ~p:~p~n", [Address, Port]),
  handler:handle(Sock).
