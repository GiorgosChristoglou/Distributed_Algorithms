.SUFFIXES: .erl .beam

MODULES = system3 process app pl beb

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

ERLC = erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all: ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

SYSTEM1 = system3

L_ERL = erl -noshell -pa ebin -setcookie pass

run: all
	$(L_ERL) -s $(SYSTEM1) start

