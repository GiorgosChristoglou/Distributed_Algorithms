.SUFFIXES: .erl .beam

MODULES = system2 process app pl

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

ERLC = erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all: ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

SYSTEM1 = system2

L_ERL = erl -noshell -pa ebin -setcookie pass

run: all
	$(L_ERL) -s $(SYSTEM1) start

