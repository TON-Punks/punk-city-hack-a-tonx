# README

This repo was created for Hack-a-TONx w/ DoraHacks and it contains exact copy of production punk city including contracts used and other important code parts. The only thing that is missing is github histoty and all credentials

## Development Setup
Here is quick guide for developmet setup

### Development Prerequisites 
* Ruby 2.7.6
* Node v16.15.0
* Postgresql
* Redis


### Setup
* `bundle install` -- install ruby gems
* `yarn install` -- install node modules
* `bundle exec rails db:setup` -- create db

### Run
* `bundle exec rails s` -- to run web server only
* `bundle exec sidekiq` -- to run background jobs(not required)

### Test with telegram
1. Install `ngrok`
2. `bundle exec rails s`
3. `ngrok http 3000`
4. Set telegram webhook for bot with the following command
`curl -X POST https://api.telegram.org/bot{BOT_CREDENTIALS}/setWebhook\?url\=https://{NGROK_URL}/telegram`
