-module(handler).

-include("record.hrl").

-export([handle/1]).
%% the api to handle Sock
%% - 6 -  op  -  data
handle(Sock) ->
    case gen_tcp:recv(Sock, 6) of
    	{ok, Bin} -> 
      		io:format("Received ~p~n", [binary_to_list(Bin)]),
    		{Len, _} = string:to_integer(binary_to_list(Bin)),
    		io:format("Len: ~w~n", [Len]),
    		{ok, OpDataBin} = gen_tcp:recv(Sock, Len),
    		OpData = binary_to_list(OpDataBin),
    		Index = string:str(OpData, ":"),
    		Op = string:substr(OpData, 1, Index),
    		Data = string:substr(OpData, Index),
    		io:format("Op: ~p, Data: ~p", [Op, Data]),
    		Pack = #package{len = Len, op = list_to_atom(Op), data = Data},
    		{ok, Pack},
    		handle(Sock);
    	{error, closed} -> 
      		io:format("Close from ~n", []),
      		gen_tcp:close(Sock),
      		{error, close}
	end.

phandle(Pack = #package{len=Len, op=Op, data=Data}) ->
	case Op of
		connect -> connect(Data);
		ddd -> ok
	end.

connect(Data) ->
    User = #user{id="", name= Data, password="", email=""},
    User.