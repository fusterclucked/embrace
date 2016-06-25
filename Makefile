BIN := embrace

define run-tests =
@failures=0; \
for result in $^; do \
	cmd="dwdiff -PL -C1 -c $1 $$result"; \
	echo $$cmd; $$cmd; \
	failures=$$(($$failures + $$?)); \
done; return $$failures
endef

.PHONY: test
test: test-boot test-spec

.PHONY: test-boot
test-boot: \
.obj/tst/boot/plain/lexer.c \
.obj/tst/boot/autosemi/lexer.c \
.obj/tst/boot/autobrace/lexer.c
	$(call run-tests, lib/lexer.c)

.PHONY: test-spec
test-spec: \
.obj/tst/spec/autosemi.c
	$(call run-tests, $${result#*/})

.PHONY: install
install: .obj/$(BIN)
	ln -sf $(shell pwd)/$^ /usr/local/bin/$(BIN)

.PHONY: clean
clean:
	rm -rf .obj

.obj \
.obj/tst/boot/plain \
.obj/tst/boot/autosemi \
.obj/tst/boot/autobrace \
.obj/tst/spec/autosemi:
	mkdir -p $@

.obj/$(BIN): lib/lexer.c lib/offside.h | .obj
	re2c --no-generation-date $< \
	| gcc -xc -std=c99 -I lib -o $@ -

.obj/tst/boot/plain/lexer.c: \
lib/lexer.c .obj/$(BIN) | .obj/tst/boot/plain
	$(word 2,$^) $< > $@

.obj/tst/boot/autosemi/lexer.c: \
tst/boot/autosemi/lexer.xc .obj/$(BIN) | .obj/tst/boot/autosemi
	$(word 2,$^) $< > $@

.obj/tst/boot/autobrace/lexer.c: \
tst/boot/autobrace/lexer.xc .obj/$(BIN) | .obj/tst/boot/autobrace
	$(word 2,$^) $< > $@

.obj/tst/spec/autosemi.c: \
tst/spec/autosemi.xc .obj/$(BIN) | .obj/tst/spec/autosemi
	$(word 2,$^) $< > $@
