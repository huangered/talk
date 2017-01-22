%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% @author huangered <huangered@hotmail.com>
%% @copyright 2016 huangered, Inc.

-module(talk_core).

-behaviour(gen_server).

-include("record.hrl").

-export([start_link/0]).

-export([handle/1, register_talk_user/1, search_talk_user/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

%% talk_users -> {user_id, talk_user_proc}
-record(state, {users, talk_users, msgPool}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

handle({Client_socket}) ->
    gen_server:cast(?MODULE, {Client_socket}).

register_talk_user({User_id, Pid}) ->
    io:format("register talk user ~p ~p~n", [User_id, Pid]),
    gen_server:call(?MODULE, {register, User_id, Pid}).

search_talk_user(Query) ->
  gen_server:call(?MODULE, {query, Query}).

%% callback

init([]) ->
    {ok, #state{users=dict:new(), talk_users=dict:new(), msgPool=dict:new()}}.

handle_call({register, User_id, Pid}, _From, State=#state{talk_users=Talk_users}) ->
  io:format("State: ~p~n",[State]),
  NTU = dict:store(User_id, Pid, Talk_users),
  {reply, ignored, State#state{talk_users=NTU}};

handle_call({query, _Query}, _From, State) ->
  {reply, ignored, State}.

handle_cast({Client_socket}, State) ->
  {ok, Pid} = talk_user_sup:start_child({Client_socket}),
  Pid ! {enter},
  {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions
-ifdef(comment).
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
-endif.