-module(test_util).

-export([start_board/0, stop_board/1]).

start_board() ->
    board:start().

stop_board(_) ->
    board:stop().
