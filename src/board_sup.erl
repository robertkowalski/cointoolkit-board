-module(board_sup).

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
        {board_crawl_sup, {board_crawl_sup, start_link, []}, permanent, 10500, supervisor, [board_crawl_sup]},
        {board_web, {board_web, start, []}, permanent, brutal_kill, worker, [board_web]}
    ],
    {ok, { {one_for_one, 5, 10}, Children} }.
