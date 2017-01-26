-module(talk_room).
-behaviour(gen_server).

-include("record.hrl").

%% API.
-export([start_link/0]).
-export([create_room/1]).
-export([add_user_to_room/2]).
-export([del_user_from_room/2]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {rooms
}).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
  io:format("talk room start link~n", []),
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

create_room(UserIdList) when is_list(UserIdList) ->
  gen_server:call(?MODULE, {create_room, UserIdList}).

add_user_to_room(User_id, Room_id) ->
  gen_server:call(?MODULE, {add_user, User_id, Room_id}).

del_user_from_room(User_id, Room_id) ->
  gen_server:call(?MODULE, {del_user, User_id, Room_id}).

%% gen_server.

init([]) ->
  io:format("talk room init~n", []),
  {ok, #state{rooms=dict:new()}}.

handle_call({create_room, UserIdList}, _From, State) ->
  io:format("create room for ~p~n",[UserIdList]),
  {reply, room_id, State};

handle_call({add_user, User_id, Room_id}, _From, State) ->
  io:format("add user ~p to room ~p~n", [User_id, Room_id]),
  {reply, ok, State};

handle_call({del_user, User_id, Room_id}, _From, State) ->
  io:format("del user ~p from room ~p~n", [User_id, Room_id]),
  {reply, ok, State};

handle_call(_Request, _From, State) ->
  {reply, ignored, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
