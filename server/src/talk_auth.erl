-module(talk_auth).
-export([auth/1]).

auth(RawData) ->
  io:format("Auth Raw Data: ~p~n", [RawData]),
  %% add try catch
  {[{<<"username">>,User},{<<"password">>,Passwd}]} = jiffy:decode(RawData),
  auth(binary_to_list(User), binary_to_list(Passwd)).
  
auth(User, Passwd) ->
  io:format("User Passwd ~p ~p ~n",[User, Passwd]),
  %% query to odbc database
  {ok, 1, User}.