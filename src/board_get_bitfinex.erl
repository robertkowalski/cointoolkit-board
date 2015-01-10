-module(board_get_bitfinex).

-export([get_normalized_values/1]).

% btcusd : ltcusd
% https://api.bitfinex.com/v1/pubticker/btcusd
%
% {
%   "mid":"277.845",
%   "bid":"277.79",
%   "ask":"277.9",
%   "last_price":"277.99",
%   "low":"275.0",
%   "high":"297.32",
%   "volume":"35059.99250412",
%   "timestamp":"1420911201.370608629"
% }


-define(URL_ROOT, "https://api.bitfinex.com/v1/pubticker/").

get_normalized_values(btc) ->
    get_normalized_values(?URL_ROOT ++ "btcusd");
get_normalized_values(ltc) ->
    get_normalized_values(?URL_ROOT ++ "ltcusd");

get_normalized_values(Url) ->
    {ok, _Status, _Header, Content} = board_request:request(Url, parsed),
    normalize(Content).

normalize(Content) ->
    #{<<"ask">> := Sell} = Content,
    #{<<"bid">> := Buy} = Content,
    #{<<"last_price">> := Last} = Content,
    #{<<"sell">> => Sell, <<"buy">> => Buy, <<"last">> => Last}.
