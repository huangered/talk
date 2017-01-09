%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(tcpserver).
-behaviour(gen_server).

%% api
-export([start_link/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
                port=0,  %% server port,
                listen   %% listen socket
               }).

%% api
start_link(Port) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).		 

%% callback

init([Port]) ->
  io:format("Start tcp listen on port ~p~n", [Port]),
  {ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false},{reuseaddr, true}]),
  spawn(fun()->accept(Listen) end),
  {ok, #state{port = Port, listen = Listen}}.

handle_call(_Req, _From, State) ->
    {reply, ignored, State}.

handle_cast(start, State) ->
    {noreply, State}.

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% private api

accept(Listen) ->
  {ok, Sock} = gen_tcp:accept(Listen),
  io:format("Accept ...~n"),
  spawn(fun() -> loop(Sock) end),
  accept(Listen).

loop(Sock) -> 
  {ok, {Address, Port}} = inet:peername(Sock),  
  io:format("Remote socket: ~p:~p~n", [Address, Port]),
  handler:handle(Sock).
