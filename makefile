compile:
	erlc hello.erl
	erlc entry.erl
start:
	erl -noshell -s hello server -s init stop
clean:
	rm *.beam
