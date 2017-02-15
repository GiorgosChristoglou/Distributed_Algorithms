.SUFFIXES: .erl .beam

MODULES = system5 process app lossyp2plinks beb

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

ERLC = erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all: ebin ${MODULES:%=ebin/%.beam}

ebin:
	mkdir ebin

SYSTEM1 = system5

L_ERL = erl -noshell -pa ebin -setcookie pass

run: all
	$(L_ERL) -s $(SYSTEM1) start

