-module(board_get_kraken).

-export([get_normalized_values/1]).

% "XBTUSD" : "LTCUSD"
% "https://api.kraken.com//0/public/Ticker?pair=XBTUSD"
%
% { error: [],
%   result:
%    { XLTCZUSD:
%     { a: [ '32.70000', '1' ],
%       b: [ '30.35121', '15' ],
%       c: [ '30.60958', '0.65273700' ],
%       v: [ '120.10472234', '120.10472234' ],
%       p: [ '30.88248', '30.87426' ],
%       t: [ 87, 87 ],
%       l: [ '30.01100', '30.01100' ],
%       h: [ '33.00000', '33.00000' ],
%       o: '31.00000' }}}

-define(URL_ROOT, "https://api.kraken.com//0/public/Ticker?pair=").

get_normalized_values(btc) ->
    get_normalized_values(?URL_ROOT ++ "XBTUSD", <<"XXBTZUSD">>);
get_normalized_values(ltc) ->
    get_normalized_values(?URL_ROOT ++ "LTCUSD", <<"XLTCZUSD">>).

get_normalized_values(Url, Entry) ->
    {ok, _Status, _Header, Content} = board_request:request(Url, parsed),
    normalize(Content, Entry).

normalize(Content, Entry) ->
    #{<<"result">> := TmpResult} = Content,
    Result = maps:get(Entry, TmpResult),
    #{<<"a">> := [Sell | _]} = Result,
    #{<<"b">> := [Buy | _]} = Result,
    #{<<"c">> := [Last | _]} = Result,
    #{<<"sell">> => Sell, <<"buy">> => Buy, <<"last">> => Last}.
