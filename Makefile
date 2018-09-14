default: build

clean-guard: guard-down
	docker-compose -p meeseeks-guard rm -f

clean-dev: 
	docker-compose rm -f

clean: clean-dev clean-guard

build:
	docker build -t coup-mobility/meeseeks .

bump-patch:
	docker-compose run meeseeks gem bump --version patch

bump-minor:
	docker-compose run meeseeks gem bump --version minor

bump-major:
	docker-compose run meeseeks gem bump --version major

release:
	docker-compose run meeseeks rake release

bundle:
	docker-compose run meeseeks bash -l -c "bundle check || bundle install"

console: bundle
	docker-compose run meeseeks bash -l -c "bundle exec bin/console"

guard-down:
	docker-compose -p meeseeks-guard down --remove-orphans

guard-up:
	docker-compose -p meeseeks-guard up -d --remove-orphans

guard-ps:
	docker-compose -p meeseeks-guard ps

guard: clean-guard guard-up
	docker-compose -p meeseeks-guard exec meeseeks bash -c "(bundle check || bundle install) && bundle exec guard"

guard-shell:
	docker-compose -p meeseeks-guard run meeseeks bash -c "(bundle check || bundle install) && bash"

rubocop:
	docker-compose run meeseeks bash -l -c "(bundle check || bundle install) && bundle exec rubocop -a"


test: guard-down guard-up
	docker-compose -p meeseeks-guard exec meeseeks bash -c "(bundle check || bundle install) && bundle exec rspec spec"

shell:
	@touch .bash_history
	docker-compose exec meeseeks bash || docker-compose run meeseeks bash
