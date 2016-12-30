-module(handler).

-include("record.hrl").

-export([handle/1]).
%% the api to handle Sock
handle(Sock) ->
    case gen_tcp:recv(Sock, 6) of
    	{ok, Bin} -> 
      		io:format("Received ~p~n", [binary_to_list(Bin)]),
    		Len = string:to_integer(binary_to_list(Bin)),
    		{ok, OpData} = gen_tcp:recv(Sock, Len),
    		Index = string:str(OpData, ":"),
    		Op = string:substr(OpData, 1, Index),
    		Data = string:substr(OpData, Index),
    		Pack = #package{len = Len, op = list_to_atom(Op), data = Data},
    		{ok, Pack};
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