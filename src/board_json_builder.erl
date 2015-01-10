-module(board_json_builder).

-export([build_json/0]).

build_json() ->
    {ok, CoinList} = application:get_env(board, coins),
    ValueList = get_values_from_store(),
    Map = build_map(ValueList, CoinList),
    jiffy:encode(Map).


build_map(ValueList, CoinList) ->
    ServiceMaps = lists:foldl(fun({S, C, Res}, Acc) ->
        lists:append([{C, {S, Res}}], Acc)
    end, [], ValueList),

    FinalList = lists:map(fun(CurrentCoin) ->
        CoinData = lists:foldl(fun({Coin, Entry}, Acc) ->
            if CurrentCoin =:= Coin ->
                lists:append([Entry], Acc);
            true ->
                Acc
            end
        end, [], ServiceMaps),
        {CurrentCoin, {CoinData}}
    end, CoinList),
    {FinalList}.

get_values_from_store() ->
    Services = get_services(),
    RedisKeys = lists:foldl(fun({_, _, Key}, Acc) ->
        KeyAsBinary = list_to_binary(Key),
        lists:append([KeyAsBinary], Acc)
    end, [], Services),
    {ok, Values} = board_data:get(lists:reverse(RedisKeys)),
    lists:zipwith(fun({S, C, _}, Res) ->
        {S, C, jiffy:decode(Res, [])}
    end, Services, Values).

get_services() ->
    {ok, Services} = application:get_env(board, services),
    lists:foldl(fun({Service, Coins}, Acc) ->
        S = binary_to_list(Service),
        List = [{Service, Coin, binary_to_list(Coin) ++ "_" ++ S} || Coin <- Coins],
        lists:append(Acc, List)
    end, [], Services).
