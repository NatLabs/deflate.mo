.PHONY: test compile-tests docs no-warn

# runs all tests using the moc interpreter (not all features in motoko are supported)
test: 
	find tests -type f -name '*.Test.mo' -print0 | xargs -0 $(mocv bin)/moc -r $(shell mops sources) -wasi-system-api

# treats warnings as errors and prints them to stdout
no-warn:
	find src -type f -name '*.mo' -print0 | xargs -0 $(mocv bin)/moc -r $(shell mops sources) -Werror -wasi-system-api

actor-tests:
	-dfx start --background
	node actor-tests.js

docs: 
	$(mocv bin)/mo-doc
	$(mocv bin)/mo-doc --format plain

gz-stat: 
	python3 ../gzstat/gzstat.py --print-block-codes --decode-blocks < output.gz > output.stat

gz:
	gzip --no-name -c output > output.gz
	node blob-to-gz -rev

gz-d:
	node blob-to-gz $(param)
	gzip -d -c output.gz > output      