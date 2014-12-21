-module(board_request).

-export([request/1, request/2]).

request(Url, parsed) ->
    {ok, Status, Header, Content} = request(Url),
    ParsedContent = jiffy:decode(Content, [return_maps]),
    {ok, Status, Header, ParsedContent}.

request(Url) ->
    case code:is_loaded(ibrowse) of
        false ->
            {ok, _} = ibrowse:start();
        _ ->
            ok
    end,
    ibrowse:send_req(Url, [], get).
