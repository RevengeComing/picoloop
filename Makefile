help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

tests: ## To run tests
	python test.py

compile: ## To compile picoloop
	cython picoloop/loop.pyx
	# python setup.py build_ext --inplace
	# python setup.py sdist

install: compile ## To install picoloop
	python setup.py install

upload: ## To upload picoloop to pypi
	python setup.py sdist upload -r pypi

clean: ## To clean working directory from builds
	rm -rf dist build picoloop.egg-info

.PHONY: compile clean tests upload
