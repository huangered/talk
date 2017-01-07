%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(core).

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

-record(state, {users, msgPool}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

handle({Socket, Pack}) ->
    gen_server:cast(?MODULE, {Socket, Pack}).

%% callback

init([]) ->
    {ok, #state{users=dict:new(), msgPool=dict:new()}}.

handle_call(_Req, _From, State) ->
    {reply, ignored, State}.

handle_cast({Socket, #package{len=_Len, op=Op, data=Data}}, State) ->
    case Op of
        connect -> 
            NewState = user_login({Socket, Data, State}),
            io:format("~p~n",[NewState]),
            {noreply, NewState};
        disconnect ->
            NewState = user_logout({Data}),
            {noreply, NewState};
        talk ->
            NewState = send_msg({Data, State}),
            {noreply, NewState}
    end.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions

user_login({Socket, Name, #state{users=Users, msgPool = MsgPool}})->
    io:format("User login ~p~n", [Name]),
    NewState = #state{users=dict:store(Name, Socket, Users), msgPool = MsgPool},
    NewState.
    %%users:start_link(1, Name, Socket).

user_logout({Name, #state{users=Users, msgPool = MsgPool}}) ->
    io:format("User logout ~p~n", [Name]),
    NewState = #state{users=dict:erase(Name, Users), msgPool = MsgPool},
    NewState.


send_msg({Data, State=#state{users=Users, msgPool = MsgPool}}) ->
    io:format("Send ~p~n", [Data]),
    case string:tokens(Data, ";") of
        [From, To, Msg] -> 
            case send(From, To, Msg, Users) of
                ok -> io:format("Send success~n", []), State;
                error ->
                    io:format("Send fail~n", []),
                    NewMsgPool = updateMsgPool(MsgPool, To, #message{from=From, date=date(), time=time(), msg=Msg}),
                    #state{users=Users, msgPool=NewMsgPool}
            end;
        _ -> io:format("Parse data wrong~n"), State
    end.

send(_From, To, Msg, Users) ->
    case dict:find(To, Users) of
        {ok, Socket} -> gen_tcp:send(Socket, Msg), ok;
        error -> error
    end.
%% MsgPool -> {user, []}
%% Msg -> #message
updateMsgPool(MsgPool, To, Msg) ->
    case dict:find(To, MsgPool) of
        {ok, UserPool} -> NewPool = UserPool++[Msg], dict:store(To, NewPool, MsgPool);
        error -> dict:store(To, [Msg])
    end.
