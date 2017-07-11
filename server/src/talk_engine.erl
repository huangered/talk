-module(talk_engine).
-behaviour(gen_statem).

-export([start/0, stop/0]).
-export([terminate/3, code_change/4, init/1, callback_mode/0]).

%% API.  This example uses a registered name name()
%% and does not link to the caller.
start() ->
    gen_statem:start({local,?MODULE}, ?MODULE, [], []).
stop() ->
    gen_statem:stop(?MODULE).

%% Mandatory callback functions
terminate(_Reason, _State, _Data) ->
    void.
code_change(_Vsn, State, Data, _Extra) ->
    {ok,State,Data}.
init([]) ->
    %% Set the initial state + data.  Data is used only as a counter.
    State = off, Data = 0,
    {ok,State,Data}.
callback_mode() -> state_functions.

handle_event(_, _, Data) ->
    %% Ignore all other events
    {keep_state,Data}.