.PHONY: cops

cops:
	bundle exec rubocop --format simple --config .rubocop.yml --parallel
