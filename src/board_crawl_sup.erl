-module(board_crawl_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->

    Children = [
        {board_crawl_worker_kraken,
          {board_crawl_worker, start_link, [board_get_kraken, [ltc, btc], "kraken"]},
            permanent, brutal_kill, worker, [board_crawl_worker]},
        {board_crawl_worker_bitfinex,
          {board_crawl_worker, start_link, [board_get_bitfinex, [ltc, btc], "bitfinex"]},
            permanent, brutal_kill, worker, [board_crawl_worker]},
        {board_crawl_worker_btce,
          {board_crawl_worker, start_link, [board_get_btce, [ltc, btc], "btce"]},
            permanent, brutal_kill, worker, [board_crawl_worker]},
        {board_crawl_worker_okcoin,
          {board_crawl_worker, start_link, [board_get_okcoin, [ltc, btc], "okcoin"]},
            permanent, brutal_kill, worker, [board_crawl_worker]}
    ],
    {ok, { {one_for_one, 5, 10}, Children} }.
