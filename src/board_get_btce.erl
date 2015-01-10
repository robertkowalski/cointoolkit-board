-module(board_get_btce).

-export([get_normalized_values/1]).

% btc_usd : ltc_usd
% https://btc-e.com/api/3/ticker/btc_usd
%
% {
%   "btc_usd": {
%     "high":292.12201,
%     "low":267.30099,
%     "avg":279.7115,
%     "vol":2868908.14039,
%     "vol_cur":10255.00696,
%     "last":271.417,
%     "buy":272.001,
%     "sell":271.417,
%     "updated":1420913180
%   }
% }


-define(URL_ROOT, "https://btc-e.com/api/3/ticker/").

get_normalized_values(btc) ->
    get_normalized_values(?URL_ROOT ++ "btc_usd", <<"btc_usd">>);
get_normalized_values(ltc) ->
    get_normalized_values(?URL_ROOT ++ "ltc_usd", <<"ltc_usd">>).

get_normalized_values(Url, Entry) ->
    {ok, _Status, _Header, Content} = board_request:request(Url, parsed),
    normalize(Content, Entry).

normalize(Content, Entry) ->
    Result = maps:get(Entry, Content),
    #{<<"sell">> := Sell} = Result,
    #{<<"buy">> := Buy} = Result,
    #{<<"last">> := Last} = Result,
    #{<<"sell">> => Sell, <<"buy">> => Buy, <<"last">> => Last}.




