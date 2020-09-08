-module(talk_handler).

-include("record.hrl").

-export([handle/1, auth_handle/1]).

%% the api to handle Sock
handle({Pid, Sock}) ->
  io:format("receive socket ~p for Pid ~p~n", [Sock, Pid]),
  case talk_packet:recv(Sock) of
    {ok, heartbeat} -> 
      io:format("headbeat~n"),
      Pid ! {heartbeat},
      handle({Pid, Sock});
    {ok, {Method, Data}} ->
      io:format("method ~p~nData ~p~n", [Method, Data]),
      Pid ! {Method, Data},
      handle({Pid, Sock});
    {error, Reason} -> 
      io:format("Close Reason ~p~n", [Reason]),
      Pid ! {disconnect},
      gen_tcp:close(Sock),
      {error, close}
  end.

auth_handle({Sock}) ->
  case talk_packet:recv(Sock) of
    {ok, {<<"auth">>, Data}} ->
      talk_auth:auth(Data);
    {ok, _} ->
      io:format("Auth_handle none operation~n", []),
      auth_handle({Sock});
    {error, Reason} ->
      {failed, Reason}
  end.