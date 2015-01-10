-module(board_request).

-export([request/1, request/2]).

request(Url, parsed) ->
    {ok, Status, Header, Content} = request(Url),
    case catch jiffy:decode(Content, [return_maps]) of
        {error, {1, invalid_json}} -> exit({invalid_json, Content});
        ParsedContent -> {ok, Status, Header, ParsedContent}
    end.

request(Url) ->
    case code:is_loaded(ibrowse) of
        false ->
            {ok, _} = ibrowse:start();
        _ ->
            ok
    end,
    ibrowse:send_req(Url, [], get).
