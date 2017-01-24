-module(talk_user).
-behaviour(gen_server).

%% API.
-export([start_link/1, 
         online/0, 
         offline/0,
         heartbeat/0,
         list_friend/0, 
         add_friend/1,
         del_friend/1]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {
  id,
  name,
  online,
  friends,
  heartbeat_time,
  client_socket,
  client_socket_pid
}).

%% API.

%%-spec start_link() -> {ok, pid()}.
start_link({Socket}) ->
  gen_server:start_link(?MODULE, [{Socket}], []).

online() ->
  gen_server:call(?MODULE, {online}).

offline() ->
  gen_server:call(?MODULE, {offline}).

list_friend() ->
  gen_server:call(?MODULE, {list_friend}).

add_friend(Id) ->
  gen_server:call(?MODULE, {add_friend, Id}).

del_friend(Id) ->
  gen_server:call(?MODULE, {del_friend, Id}).

heartbeat() ->
  gen_server:cast(?MODULE, {heartbeat}).

%% gen_server.

init([{Socket}]) ->
  io:format("Connect from ~p~n", [Socket]),
  {ok, #state{client_socket=Socket}}.

handle_call({online}, _From, State) ->
  {reply, ignored, State#state{online=true}};

handle_call({offline}, _From, State) ->
  {reply, ignored, State#state{online=false}};

handle_call({list_friend}, _From, State) ->
  {reply, ignored, State};

handle_call({add_friend}, _From, State) ->
  {reply, ignored, State};

handle_call({del_friend}, _From, State) ->
  {reply, ignored, State}.

handle_cast({heartbeat}, State) ->
  {noreply, State#state{heartbeat_time={date(), time()}}}.

%% read user info from socket
handle_info({enter}, State=#state{client_socket=Socket}) ->
  io:format("Enter from socket ~p~n", [Socket]),
  io:format("Start to recv msg......~n", []),
  Pid = self(),
  Client_socket_pid = spawn(fun() -> recv({Pid, Socket}) end),
  io:format("User Pid ~p~n", [self()]),
  io:format("Client Socket Pid ~p~n", [Client_socket_pid]),
  {noreply, State};
             
handle_info({heartbeat}, State) ->
  NS = State#state{heartbeat_time={date(), time()}},
  io:format("State ~p ~n",[NS]),
  {noreply, NS};

handle_info({disconnect}, State) ->
  io:format("disconnect~n", []),
  NS = State#state{online=false},
  io:format("State ~p ~n",[NS]),
  {noreply, NS};

handle_info({auth, Id, Username}, State) ->
  io:format("auth ~p~p~n", [Id, Username]),
  NS = State#state{id=Id, name=Username},
  {noreply, NS};

%% create talk room
handle_info({create_room, UserIdList}, State) ->
  Id = talk_room:create_room(UserIdList),
  self() ! {sendback, talk_packet:pack(<<"create_room_resp">>, integer_to_binary(Id))},
  {noreply, State};

%% add user to talk room
handle_info({add_user_to_room, User_id, Room_id}, State) ->
  Result = talk_room:add_user_to_room(User_id, Room_id),
  self() ! {sendback, talk_packet:pack(<<"add_user_to_room_resp">>, atom_to_binary(Result, utf8))},
  {noreply, State};

%% send the message back to client
handle_info({sendback, Msg}, State=#state{client_socket=Socket}) ->
  talk_packet:send(Socket, Msg),
  {noreply, State};

handle_info({Method, Data}, State) ->
  io:format("Event ~p ~p ~n",[Method, Data]),
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

recv({Pid, Socket}) ->
  case talk_handler:auth_handle({Socket}) of
    {ok, Id, Name} ->
      io:format("auth ok~n",[]),
      Pid ! {auth, Id, Name}, 
      talk_handler:handle({Pid, Socket});
    {fail, _Reason} -> recv({Pid, Socket})
  end.