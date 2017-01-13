-module(talk_packet).

-export([recv/1, send/2]).

-export([pack/2, unpack/1]).

recv(Socket) ->
  case gen_tcp:recv(Socket, 2) of
    {ok, PacketLenBin} ->
      io:format("Bin ~p~n", [PacketLenBin]),
      <<PacketLen:16>> = PacketLenBin,
      io:format("Len ~p~n", [PacketLen]),
      if 
        PacketLen > 100 -> io:format("Tool long"), recv(Socket);
        true -> true
      end,
      case gen_tcp:recv(Socket, PacketLen) of
        {ok, <<"00">>} ->
          {ok, heartbeat};
        {ok, RealData} ->
          io:format("recv data ~p~n", [RealData]),
          {ok, unpack(RealData)};
        {error, Reason} ->
   	  io:format("read packet data failed with reason: ~p on socket ~p~n", [Reason, Socket]),
	  {error, Reason}
       end;
    {error, Reason} -> 
      io:format("read packet length failed with reason: ~p on socket ~p~n", [Reason, Socket]),
      {error, Reason}
  end.

send(Socket, Bin) ->
  io:format("packet send ~p~n", [Bin]),
  Len = byte_size(Bin),
  SendBin = <<Len:16, Bin/binary>>,
  case gen_tcp:send(Socket, SendBin) of
    ok -> io:format("!!!packet send ~p ok~n", [SendBin]), ok;
    {error, closed} -> {error, closed};
    {error, Reason} -> {error, Reason}
  end.

%% 
pack(Method, Data) ->
  MethodLen = length(binary_to_list(Method)),
  <<MethodLen:8, Method/binary, Data/binary>>.

unpack(RawData) ->
  <<MethodLen:8, Bin/binary>> = RawData,
  <<Method:MethodLen/binary, Data/binary>> = Bin,
  {Method, Data}.