.SUFFIXES: .erl .beam

.erl.beam:
	erlc -W $<

ERL = erl -boot start_clean

MODS = hello entry handler talk_server	

all: compile start
	

compile: ${MODS:%=%.beam}

start:
	erl -noshell -s hello server -s init stop
clean:
	rm -rf *.beam erl_crash.dump