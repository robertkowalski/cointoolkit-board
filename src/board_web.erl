-module(board_web).

-export([start/0, stop/1]).

start() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", hello_world_handler, []}
        ]}
    ]),
    {ok, Port} = application:get_env(http_port),
    {ok, ListenerCount} = application:get_env(http_listener_count),
    cowboy:start_http(http, ListenerCount, [{port, Port}], [
        {env, [{dispatch, Dispatch}]}
    ]).

stop(Pid) ->
    cowboy:stop_listener(Pid).
