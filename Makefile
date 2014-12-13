NODE ?= "board"
APPNAME ?= "board_app"
REBAR=`which rebar || ./rebar`
CONFIG ?= "priv/app.config"

RUN := erl -pa ebin -pa deps/*/ebin -smp enable -s lager -boot start_sasl -config ${CONFIG} ${ERL_ARGS}

all:
	${REBAR} get-deps compile

quick:
	${REBAR} skip_deps=true compile

clean:
	${REBAR} clean

quick_clean:
	${REBAR} skip_deps=true clean

run: quick
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@`hostname` -s ${APPNAME}; \
	else ${RUN} -s ${APPNAME}; \
	fi

eunit: quick
	ERL_FLAGS="-config test/eunit" rebar eunit
