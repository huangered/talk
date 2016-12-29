-module(conn).
-export([create/1, accept/2, close/1]).

create(Port) ->
  {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]),
  {ok, Sock} = gen_tcp:accept(LSock),
  Sock.

accept(Sock, Len) ->
  case gen_tcp:recv(Sock, Len) of
    {ok, Bin} -> io:format("received ~p~n", [Bin]),
                 {ok, Bin};
    {error, closed} -> {ok, "error"}
  end.

close(Sock) ->
  ok = gen_tcp:close(Sock).


                                                          