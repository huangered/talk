-module(conn).
-export([create/1, accept/2, close/1]).

create(Port) ->
  {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false},{reuseaddr, true}]),
  {ok, Sock} = gen_tcp:accept(LSock),
  Sock.

accept(Sock, Len) ->
  {ok, {Address, Port}} = inet:peername(Sock),  
  io:format("socket: ~p ~p~n", [Address, Port]),
  case gen_tcp:recv(Sock, 0) of
    {ok, Bin} -> io:format("received ~p~n", [Bin]),
                 {ok, Bin};
    {error, closed} -> {ok, "error"}
  end.

close(Sock) ->
  ok = gen_tcp:close(Sock).


                                                          