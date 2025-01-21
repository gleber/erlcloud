.PHONY: all get-deps clean compile run eunit check doc hex-publish rebar3-install

REBAR=$(shell which rebar3 || echo ./rebar3)

all: compile

clean:
	@$(REBAR) clean

compile:
	@$(REBAR) compile

run:
	$(REBAR) shell

check_warnings:
	@$(REBAR) as warnings compile

warnings:
	@$(REBAR) as test compile

eunit:
	@ERL_FLAGS="-config $(PWD)/eunit" $(REBAR) eunit

check:
	@$(REBAR) as dialyzer do dialyzer --update-plt

doc:
	@$(REBAR) edoc

hex-publish:
	@$(REBAR) hex publish

rebar3-install:
	wget https://s3.amazonaws.com/rebar3/rebar3
	chmod a+x rebar3
