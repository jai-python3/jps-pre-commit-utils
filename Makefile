.PHONY: install test lint build clean publish

install:
	pip install -e .

test:
	pytest -v --disable-warnings

lint:
	flake8 src tests

build:
	python -m build

publish:
	twine upload dist/*

clean:
	rm -rf build dist *.egg-info
