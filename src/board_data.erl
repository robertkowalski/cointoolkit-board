-module(board_data).

-behaviour(gen_server).

% Client API
-export([start_link/2, set/2, get/1, stop/0]).

% Server API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

% Client
start_link(Host, Port) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Host, Port], []).

set(Key, Value) ->
    gen_server:call(?MODULE, {save, Key, Value}).

get(Key) ->
    gen_server:call(?MODULE, {get, Key}).

stop() ->
    gen_server:call(?MODULE, terminate).

% Server
init([Host, Port]) ->
    {ok, Client} = eredis:start_link(Host, Port),
    {ok, Client}.

handle_call({get, Key}, _From, Client) ->
    Response = eredis:q(Client, [<<"MGET">> | [Key]]),
    {reply, Response, Client};
handle_call({save, Key, Value}, _From, Client) ->
    KeyValuePairs = [Key, Value],
    Response = eredis:q(Client, [<<"MSET">> | KeyValuePairs]),
    {reply, Response, Client};
handle_call(terminate, _From, Client) ->
    {stop, normal, ok, Client}.

handle_cast(_Msg, Client) ->
    {noreply, Client}.

handle_info(Msg, Client) ->
    io:format("Unexpected message: ~p~n", [Msg]),
    {noreply, Client}.

terminate(normal, Client) ->
    eredis:stop(Client),
    ok.

code_change(_OldVsn, Client, _Extra) ->
    {ok, Client}.
