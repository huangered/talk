-module(server_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
Dispatch = cowboy_router:compile([
	   {'_', [ {"/hello", hello_handler, []},
			{"/", toppage_handler, []}
			      ]}
			      ]),
			      {ok, _} = cowboy:start_clear(http, 100, [{port, 8082}], #{
			      	   env => #{dispatch => Dispatch}
				   }),
    server_sup:start_link().

stop(_State) ->
	ok.
