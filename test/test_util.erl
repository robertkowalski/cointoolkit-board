-module(test_util).

-export([start_board/0, stop_board/1]).

start_board() ->
    ibrowse:start(),
    board_app:start().

stop_board(_) ->
    board_app:stop(),
    ibrowse:stop(),
    ok.
