-module(board_crawl_worker).

-behaviour(gen_server).

% Client API
-export([start_link/3, close/1]).

% Server API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(DELAY, 5000).

% Client
start_link(M, Coins, Service) ->
    {ok, RedisPort} = application:get_env(board, redis_port),
    {ok, RedisHost} = application:get_env(board, redis_host),
    board_data:start_link(RedisHost, RedisPort),
    gen_server:start_link({local, list_to_atom(Service)}, ?MODULE, [M, Coins, Service], []).

close(_) ->
    ok.

% Server
init([Module, Coins, Service]) ->
    {ok, [Module, Coins, Service], ?DELAY}.

handle_call(terminate, _From, State) ->
    {stop, normal, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(timeout, [Module, [Coin | Coins], Service]) ->
    get_value_encode_and_save(Module, Coin, Service),
    NewOrderedCoins = lists:append(Coins, [Coin]),
    {noreply, [Module, NewOrderedCoins, Service], ?DELAY};

handle_info(Msg, State) ->
    io:format("Unexpected message: ~p~n", [Msg]),
    {noreply, State, ?DELAY}.

terminate({invalid_json, Content}, Args) ->
    io:format("bad_return_value -- ~p ~p ~n", [Args, Content]),
    ok;
terminate(normal, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% Private
get_value_encode_and_save(Module, Coin, Service) ->
    Values = erlang:apply(Module, get_normalized_values, [Coin]),
    Key = lists:concat([Coin, "_", Service]),
    Map = board_decorate_json:decorate(Values, Coin, Service),
    board_data:set(Key, jiffy:encode(Map)).
