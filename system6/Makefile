.SUFFIXES: .erl .beam

MODULES = system6 process app lossyp2plinks beb rb

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

ERLC = erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all: ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

SYSTEM1 = system6

L_ERL = erl -noshell -pa ebin -setcookie pass

run: all
	$(L_ERL) -s $(SYSTEM1) start

