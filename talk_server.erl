%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(talk_server).

-behaviour(gen_server).

-include("record.hrl").

-export([start_link/0]).

-export([handle/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {users}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

handle({Socket, Pack}) ->
    gen_server:cast(?MODULE, {Socket, Pack}).

%% callback

init([]) ->
    {ok, #state{users=dict:new()}}.

handle_call(_Req, _From, State) ->
    {reply, ignored, State}.

handle_cast({Socket, Pack = #package{len=_Len, op=Op, data=Data}}, State) ->
    case Op of
        connect -> 
            NewState = user_login({Socket, Data, State}),
            io:format("~p~n",[NewState]),
            {noreply, NewState};
        disconnect ->
            NewState = user_logout({Data}),
            {noreply, NewState};
        talk ->
            send_msg({Data}),
            {noreply, State}
    end.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions

user_login({Socket, Name, State=#state{users=Users}})->
    io:format("User login ~p~n", [Name]),
    NewState = #state{users=dict:store(Name, Socket, Users)}.

    %%users:start_link(1, Name, Socket).

user_logout({Name, State=#state{users=Users}}) ->
    io:format("User logout ~p~n", [Name]),
    NewState = #state{users=dict:erase(Name, Users)}.


send_msg({_Data}) ->
    io:format("Send").