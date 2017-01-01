-module(hello).
-export([hello_world/0, report/0, client/0, server/0]).

hello_world() -> io:fwrite("hello, world\n").

report() ->
  receive
    X -> io:format("received ~p~n",[X]),
    report()
  end.

client() ->
    SomeHostInNet = "localhost", % to make it runnable on one machine
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, 5678, 
                                 [binary, {packet, 0}]),
    ok = gen_tcp:send(Sock, "Some Data"),
    ok = gen_tcp:send(Sock, "Some Data1"),
    ok = gen_tcp:close(Sock).

server() ->
    talk_server:start_link(),
    entry:start_link(12345),
    entry:start(),
    report().

