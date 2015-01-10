-module(board_web).

-export([start/0, stop/1]).

start() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/v2", board_web_api_v2_handler, []}
        ]}
    ]),
    {ok, Port} = application:get_env(http_port),
    {ok, ListenerCount} = application:get_env(http_listener_count),
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, RedisHost} = application:get_env(board, redis_host),
    board_data:start_link(RedisHost, RedisPort),
    cowboy:start_http(http, ListenerCount, [{port, Port}], [
        {env, [{dispatch, Dispatch}]}
    ]).

stop(Pid) ->
    cowboy:stop_listener(Pid).
