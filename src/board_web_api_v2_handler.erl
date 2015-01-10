-module(board_web_api_v2_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ok, Req2} = cowboy_req:reply(200, [
        {<<"content-type">>, <<"application/json">>}
    ], board_json_builder:build_json(), Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
