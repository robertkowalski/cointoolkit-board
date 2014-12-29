-module(board_data_tests).
-include_lib("eunit/include/eunit.hrl").


setup() ->
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, RedisHost} = application:get_env(board, redis_host),
    board_data:start_link(RedisHost, RedisPort),
    {ok, RedisClient} = eredis:start_link(RedisHost, RedisPort),
    KeyValuePairs = [<<"kraken">>, <<"value1">>],
    {ok, <<"OK">>} = eredis:q(RedisClient, [<<"MSET">> | KeyValuePairs]),
    {RedisClient}.

teardown({RedisClient}) ->
    eredis:stop(RedisClient),
    board_data:stop(),
    ok.

board_test_() ->
    {
        foreach,
        fun setup/0, fun teardown/1,
        [
            fun it_should_get_values/1,
            fun it_should_get_multiple_values/1,
            fun it_should_set_values/1
        ]
    }.


it_should_get_values({_}) ->
    ?_assertEqual([<<"value1">>],
        begin
            {Status, Value} = board_data:get(<<"kraken">>),
            Value
        end).

it_should_get_multiple_values({RedisClient}) ->
    ?_assertEqual([<<"value1">>, <<"value2">>],
        begin
            KeyValuePairs = [<<"kraken">>, <<"value1">>, <<"octocoin">>, <<"value2">>],
            {ok, <<"OK">>} = eredis:q(RedisClient, [<<"MSET">> | KeyValuePairs]),
            {Status, Value} = board_data:get([<<"kraken">>, <<"octocoin">>]),
            Value
        end).

it_should_set_values({RedisClient}) ->
    ?_assertEqual([<<"Ente">>],
        begin
            board_data:set(<<"kraken">>, <<"Ente">>),
            {ok, Value} = eredis:q(RedisClient, [<<"MGET">> | [<<"kraken">>]]),
            Value
        end).
