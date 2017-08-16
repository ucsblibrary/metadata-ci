.PHONY: cops test

cops:
	bundle exec rubocop --format simple --config .rubocop.yml --parallel

test:
	bundle exec rake test
