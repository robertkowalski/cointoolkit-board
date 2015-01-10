-module(board_json_builder_tests).
-include_lib("eunit/include/eunit.hrl").


setup() ->
    application:load(board),
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, RedisHost} = application:get_env(board, redis_host),
    {ok, RedisClient} = eredis:start_link(RedisHost, RedisPort),
    KrakenValueBtc = jiffy:encode(#{<<"sell">> => 1, <<"buy">> => 2, <<"last">> => 3}),
    KrakenValueLtc = jiffy:encode(#{<<"sell">> => 7, <<"buy">> => 8, <<"last">> => 9}),
    OtherValue = jiffy:encode(#{<<"sell">> => 4, <<"buy">> => 5, <<"last">> => 6}),
    KeyValuePairs = [<<"btc_kraken">>, KrakenValueBtc, <<"btc_other">>, OtherValue, <<"ltc_kraken">>, KrakenValueLtc],
    {ok, <<"OK">>} = eredis:q(RedisClient, [<<"MSET">> | KeyValuePairs]),
    board_data:start_link(RedisHost, RedisPort),
    {RedisClient}.

teardown({RedisClient}) ->
    board_data:stop(),
    eredis:stop(RedisClient),
    ok.

board_test_() ->
    {
        foreach,
        fun setup/0, fun teardown/1,
        [
            fun it_should_have_kraken_in_json/1,
            fun it_should_have_other_in_json/1
        ]
    }.

it_should_have_kraken_in_json(_) ->
    ?_assertEqual(1,
        begin
            JSON = board_json_builder:build_json(),
            TmpResult = jiffy:decode(JSON, [return_maps]),
            Btc = maps:get(<<"btc">>, TmpResult),
            Kraken = maps:get(<<"kraken">>, Btc),
            maps:get(<<"sell">>, Kraken)
        end).

it_should_have_other_in_json(_) ->
    ?_assertEqual(4,
        begin
            JSON = board_json_builder:build_json(),
            TmpResult = jiffy:decode(JSON, [return_maps]),
            Btc = maps:get(<<"btc">>, TmpResult),
            Other = maps:get(<<"other">>, Btc),
            maps:get(<<"sell">>, Other)
        end).
