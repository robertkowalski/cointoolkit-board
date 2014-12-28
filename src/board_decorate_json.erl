-module(board_decorate_json).

-export([decorate/3]).

decorate(Map, Coin, Service) ->
    Ticker = lists:concat([Coin, "_usd"]),
    AdditionalElements = #{
        <<"cointoolkit_timestamp">> => get_timestamp(),
        <<"ticker">> => list_to_binary(Ticker),
        <<"service">> => list_to_binary(Service)
    },
    maps:merge(AdditionalElements, Map).

get_timestamp() ->
    {Part1, Part2, _} = os:timestamp(),
    list_to_integer(integer_to_list(Part1) ++ integer_to_list(Part2)).
