-module(board_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-export([start/0, stop/0]).

start() ->
    application:ensure_all_started(board).

stop() ->
    application:stop(cowboy),
    application:stop(ranch),
    application:stop(lager),
    application:stop(board).


%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    board_sup:start_link().

stop(_State) ->
    ok.
