-module(entry).
-export([server/1]).

server(Port) ->
  {ok, Listen} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false},{reuseaddr, true}]),
  accept(Listen).

accept(Listen) ->
  {ok, Sock} = gen_tcp:accept(Listen),
  spawn(fun() -> loop(Sock) end),
  accept(Listen).

close(Sock) ->
  ok = gen_tcp:close(Sock).

loop(Sock) -> 
  {ok, {Address, Port}} = inet:peername(Sock),  
  io:format("Remote socket: ~p:~p~n", [Address, Port]),
  case gen_tcp:recv(Sock, 0) of
    {ok, Bin} -> 
      io:format("Received ~p~n", [binary_to_list(Bin)]),
      loop(Sock);
    {error, closed} -> 
      io:format("Close from ~p:~p~n", [Address, Port]),
      close(Sock)
  end.


                                                          