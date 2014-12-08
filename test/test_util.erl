-module(test_util).

-export([start_board/0, stop_board/1]).

start_board() ->
    ibrowse:start(),
    board:start().

stop_board(_) ->
    ibrowse:stop(),
    board:stop().
