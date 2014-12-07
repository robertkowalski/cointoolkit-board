-module(board_tests).
-include_lib("eunit/include/eunit.hrl").


setup() ->
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, RedisClient} = eredis:start_link("localhost", RedisPort),
    KeyValuePairs = [<<"kraken">>, <<"value1">>],
    {ok, <<"OK">>} = eredis:q(RedisClient, [<<"MSET">> | KeyValuePairs]),
    RedisClient.

teardown(RedisClient) ->
    eredis:stop(RedisClient),
    ok.

board_test_() ->
    {
        setup,
        fun test_util:start_board/0, fun test_util:stop_board/1,
        {
            foreach,
            fun setup/0, fun teardown/1,
            [
                fun redis_should_run/1
            ]
        }
    }.

redis_should_run(RedisClient) ->
    ?_assertEqual([<<"value1">>],
        begin
            {ok, Values} = eredis:q(RedisClient, [<<"MGET">> | [<<"kraken">>]]),
            Values
        end).
