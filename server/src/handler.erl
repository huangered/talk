-module(handler).

-include("record.hrl").

-export([handle/1]).
%% the api to handle Sock
%% - 6 -  op  -  data
handle(Sock) ->
    case gen_tcp:recv(Sock, 0) of
    	{ok, Bin} -> 
        Line = binary_to_list(Bin),
        {Len, _ } = string:to_integer(string:substr(Line, 1, 6)),
    		OpData = string:substr(Line, 7),
    		Index = string:str(OpData, ":"),
    		Op = string:substr(OpData, 1, Index - 1),
    		Data = string:substr(OpData, Index + 1),
        TrimData = string:substr(Data, 1, string:len(Data) - 2 ),
    		Pack = #package{len = Len, op = list_to_atom(Op), data = TrimData},
        io:format("Package ~p~n", [Pack]),
    		talk_server:handle({Sock, Pack}),
        handle(Sock);
    	{error, closed} -> 
      		io:format("Close from ~n", []),
      		gen_tcp:close(Sock),
      		{error, close}
	end.
