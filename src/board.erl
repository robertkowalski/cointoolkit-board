-module(board).

-export([start/0, stop/0]).

start() -> application:ensure_all_started(board).

stop() -> application:stop(board).
