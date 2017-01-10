%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(message_pool).

-behaviour(gen_server).

-export([start_link/0]).
-export([push/2, pop/1, detail/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {messages, count}).

%% public api
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

push(ToUser, Message) ->
    gen_server:call(?MODULE, {push, ToUser, Message}).

pop(User) ->
    gen_server:call(?MODULE, {pop, User}).

detail() ->
    gen_server:call(?MODULE, {detail}).

%% callback
init([]) ->
    Messages = dict:new(), %% will load in the db
    Count = 0,             %% will load in the db
    io:format("Start message pool, count: ~p~n", [Count]),
    {ok, #state{messages = Messages, count = Count}}.

handle_call({push, ToUser, Msg}, _From, #state{messages=Pool, count=Count}) ->
    case dict:find(ToUser, Pool) of
        {ok, Msgs} -> 
            NewMsgs = Msgs++[Msg], 
            Npool = dict:store(ToUser, NewMsgs, Pool),
            {reply, ignored, #state{messages=Npool, count=Count}};
        error -> 
            Npool = dict:store(ToUser, [Msg], Pool),
            C = Count+1,
            {reply, ignored, #state{messages=Npool, count=C}}
    end;

handle_call({pop, User}, _From, State=#state{messages=Pool}) ->
    case dict:find(User, Pool) of
        {ok, Msgs} -> {reply, Msgs, State};
        error -> {reply, nofound, State}
    end;

handle_call({detail}, _From, State) ->
    {reply, "detail", State}.    

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions