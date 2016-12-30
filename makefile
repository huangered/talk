compile:
	erlc hello.erl
	erlc entry.erl
start:
	erl -noshell -s hello hello_world -s init stop
clean:
	rm *.beam
