# RAILS TEST APP

Heroku App URL `https://salty-jenea.herokuapp.com`

Ruby version: 2.6.3

## SETUP

1. bundle install
2. create your personal "application.yml" filee from .example provided
```
    cp config/application.example.yml config/application.yml
```
3. create and migrate the database
```
    bundle exec rake db:create db:migrate
```