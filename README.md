[![Maintainability](https://api.codeclimate.com/v1/badges/ff0dff43b4acf5d77303/maintainability)](https://codeclimate.com/github/SUSE/geekos-backend/maintainability)
[![CodeQL](https://github.com/SUSE/geekos-backend/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/SUSE/geekos-backend/actions/workflows/codeql-analysis.yml)
[![Brakeman Scan](https://github.com/SUSE/geekos-backend/actions/workflows/brakeman-analysis.yml/badge.svg)](https://github.com/SUSE/geekos-backend/actions/workflows/brakeman-analysis.yml)
[![Rspec](https://github.com/SUSE/geekos-backend/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/SUSE/geekos-backend/actions/workflows/rubyonrails.yml)
[![Coverage](https://codecov.io/gh/SUSE/geekos-backend/branch/main/graph/badge.svg?token=65YS1lM0mV)](https://codecov.io/gh/SUSE/geekos-backend)

# Geekos

Geekos is a server application to query and manage a community of users.
It can sync user attributes and hierarchy from LDAP and other backend systems.

Features:

* Fast fulltext search over defined attributes
* Sync + combine user data from different systems into a flexible schema (MongoDB)
* Overwriting of defined fields
* Extensible crawlers to collect user data from different backend systems
* REST & GraphQL JSON APIs
* Storing user images
* Supporting location/room/coordinates per user


## Development Setup

As a persistent storage, the app uses [MongoDB](https://www.mongodb.com/).
The simplest way is to start it in a container (set a local path as 'local_volume'
to persist the database):

`docker run -d --name geekos-mongo -v <local_volume>:/data/db -p 27017:27017 mongo:5.0`

Geekos reads its configuration from environment variables, or from the file `config/application.yml`
using [figaro](https://github.com/laserlemon/figaro).

Please see `.ruby_version` for the required Ruby, install bundler with
`gem install bundler:2.3.7` and install dependencies by calling `bundle`.
To start the server, run: `> bundle exec rails s -b 0.0.0.0`

To export the graphql schema, run: `bundle exec rake graphql:export`

## Importing data

* To run the default set of crawlers, run: `Crawler.run`
* To run only one specific crawler, run for example: `Crawler::Ldap.new.run`
* After initial import, create indexes: `> bundle exec rake db:mongoid:create_indexes`


## Testing

To run the code linting and test suite, run: `bunde exec rubocop` and `bundle exec rspec`.
The repository is also covered with automatic Github Actions jobs. You can
run those locally with the tool [act](https://github.com/nektos/act).
For example `act -j test`.

## Deployment

### Docker

The container image gets build with: <br>
`docker build -t geekos-backend .`

You can run the image with this command: <br> `docker run -p 3000:3000 -e geekos_mongodb_server=172.17.0.1 -e SECRET_KEY_BASE=5fadcd -e RAILS_LOG_TO_STDOUT=true --rm geekos-backend` <br>
(172.17.0.1 is the Docker host IP, see config/application.yml.template for all available env vars)

To open a shell inside of the container: <br> `docker run --rm -ti geekos-backend /bin/bash`
