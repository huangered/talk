%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(talk_server).

-behaviour(gen_server).

-export([start_link/0]).

-export([user_login/0, user_logout/0, send_msg/3]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

user_login()->
    io:format("User login").

user_logout() ->
    io:format("User logout").

send_msg(From, To, Msg) ->
    io:format("Send ~p from ~p to ~p~n", [ Msg, From, To]).

%% callback

init([]) ->
    {ok, #state{}}.

handle_call({login, Sock}, _From, State) ->
    {reply, ignored, State};

handle_call({logout}, _From, State) ->
    {reply, ignored, State}.

handle_cast({From, To, Msg}, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions