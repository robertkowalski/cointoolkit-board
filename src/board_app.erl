-module(board_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", hello_world_handler, []}
        ]}
    ]),
    {ok, Port} = application:get_env(http_port),
    {ok, ListenerCount} = application:get_env(http_listener_count),
    {ok, _} = cowboy:start_http(http, ListenerCount, [{port, Port}], [
        {env, [{dispatch, Dispatch}]}
    ]),
    board_sup:start_link().

stop(_State) ->
    ok.
