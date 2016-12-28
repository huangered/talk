start:
	erl -noshell -s hello hello_world -s init stop
compile:
	erlc hello.erl
clean:
	rm *.beam
