-module(board_tests).
-include_lib("eunit/include/eunit.hrl").


setup() ->
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, HttpPort} = application:get_env(board, http_port),
    Url = lists:concat(["http://localhost:", HttpPort, "/"]),
    {ok, RedisClient} = eredis:start_link("localhost", RedisPort),
    KeyValuePairs = [<<"kraken">>, <<"value1">>],
    {ok, <<"OK">>} = eredis:q(RedisClient, [<<"MSET">> | KeyValuePairs]),
    {RedisClient, Url}.

teardown({RedisClient, Url}) ->
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
                fun redis_should_run/1,
                fun the_board_should_reply_hello_world/1
            ]
        }
    }.

redis_should_run({RedisClient, _}) ->
    ?_assertEqual([<<"value1">>],
        begin
            {ok, Values} = eredis:q(RedisClient, [<<"MGET">> | [<<"kraken">>]]),
            Values
        end).

the_board_should_reply_hello_world({_, Url}) ->
    ?_assertEqual("Hello world!",
        begin
            {ok, _Status, _Header, Content} = ibrowse:send_req(Url, [], get),
            Content
        end).
