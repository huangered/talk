-module(talk_odbc).
-behaviour(gen_server).

%% API.
-export([start_link/0, query_user/2]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {conn}).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
	gen_server:start_link(?MODULE, [], []).

query_user(User, Passwd) ->
  gen_server:call(?MODULE, {query, User, Passwd}).

%% gen_server.

init([]) ->
	{ok, #state{}}.

handle_call({query, _User, _Passwd}, _From, State) ->
	{reply, ignored, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
