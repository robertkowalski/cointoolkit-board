-module(decorate_json_tests).
-include_lib("eunit/include/eunit.hrl").


setup() ->
    #{<<"sell">> => 123, <<"buy">> => 444, <<"last">> => 999}.

teardown(_) ->
    ok.

board_test_() ->
    {
        foreach,
        fun setup/0, fun teardown/1,
        [
            fun it_should_add_a_timestamp/1,
            fun it_should_add_a_ticker/1,
            fun it_should_add_a_service/1
        ]
    }.


it_should_add_a_timestamp(Map) ->
    ?_assertEqual(true,
        begin
            NewMap = board_decorate_json:decorate(Map, "btc", "kraken"),
            #{<<"cointoolkit_timestamp">> := Time} = NewMap,
            is_integer(Time)
        end).

it_should_add_a_ticker(Map) ->
    ?_assertEqual(<<"btc_usd">>,
        begin
            NewMap = board_decorate_json:decorate(Map, "btc", "kraken"),
            #{<<"ticker">> := Ticker} = NewMap,
            Ticker
        end).

it_should_add_a_service(Map) ->
    ?_assertEqual(<<"kraken">>,
    begin
        NewMap = board_decorate_json:decorate(Map, "btc", "kraken"),
        #{<<"service">> := Service} = NewMap,
        Service
    end).
