-module(board_get_okcoin).

-export([get_normalized_values/1]).

% btc_usd : ltc_usd
% https://www.okcoin.com/api/v1/ticker.do?symbol=btc_usd
%
% {
%   "date":"1420913847",
%   "ticker": {
%     "buy":"270.84",
%     "high":"289.48",
%     "last":"270.84",
%     "low":"270.6",
%     "sell":"272.12",
%     "vol":"10405.974"
%   }
% }


-define(URL_ROOT, "https://www.okcoin.com/api/v1/ticker.do?symbol=").

get_normalized_values(btc) ->
    get_normalized_values(?URL_ROOT ++ "btc_usd");
get_normalized_values(ltc) ->
    get_normalized_values(?URL_ROOT ++ "ltc_usd");

get_normalized_values(Url) ->
    {ok, _Status, _Header, Content} = board_request:request(Url, parsed),
    normalize(Content).

normalize(Content) ->
    Result = maps:get(<<"ticker">>,  Content),
    #{<<"sell">> := Sell} = Result,
    #{<<"buy">> := Buy} = Result,
    #{<<"last">> := Last} = Result,
    #{<<"sell">> => Sell, <<"buy">> => Buy, <<"last">> => Last}.
