-module(board_web_tests).
-include_lib("eunit/include/eunit.hrl").


setup() ->
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, RedisHost} = application:get_env(board, redis_host),
    {ok, HttpPort} = application:get_env(board, http_port),
    Url = lists:concat(["http://localhost:", HttpPort, "/v2"]),
    {ok, RedisClient} = eredis:start_link(RedisHost, RedisPort),
    KrakenValueBtc = jiffy:encode(#{<<"sell">> => 1, <<"buy">> => 2, <<"last">> => 3}),
    KrakenValueLtc = jiffy:encode(#{<<"sell">> => 7, <<"buy">> => 8, <<"last">> => 9}),
    OtherValue = jiffy:encode(#{<<"sell">> => 4, <<"buy">> => 5, <<"last">> => 6}),
    KeyValuePairs = [<<"btc_kraken">>, KrakenValueBtc, <<"btc_other">>, OtherValue, <<"ltc_kraken">>, KrakenValueLtc],
    {ok, <<"OK">>} = eredis:q(RedisClient, [<<"MSET">> | KeyValuePairs]),
    {RedisClient, Url}.

teardown({RedisClient, _Url}) ->
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
                fun the_board_should_reply_json/1,
                fun the_board_should_reply_with_content_type_application_json/1
            ]
        }
    }.


the_board_should_reply_json({_, Url}) ->
    ?_assertEqual("{\"ltc\":{\"kraken\":{\"sell\":7,\"last\":9,\"buy\":8}},\"btc\":{\"" ++
        "kraken\":{\"sell\":1,\"last\":3,\"buy\":2},\"other\":{\"sell\":4,\"last\":6,\"buy\":5}}}",
        begin
            {ok, _Status, _Header, Content} = board_request:request(Url),
            Content
        end).

the_board_should_reply_with_content_type_application_json({_, Url}) ->
    ?_assertEqual("application/json",
        begin
            {ok, _Status, Header, _Content} = board_request:request(Url),
            proplists:get_value("content-type", Header)
        end).
