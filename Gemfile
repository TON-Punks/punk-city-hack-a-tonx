source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.6"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 6.1.5"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.0"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

gem "aasm"
gem "after_commit_everywhere"
gem "anyway_config", "~> 2.0"
gem "aws-sdk-s3"
gem "blueprinter"
gem "dotenv-rails", "~> 2.8"
gem "draper"
gem "dry-struct"
gem "honeybadger", "~> 4.0"
gem "http"
gem "httparty"
gem "interactor"
gem "rack-attack"
gem "redis" # hiredis doesn't support ssl connection
gem "redlock"
gem "sidekiq"
gem "sidekiq-scheduler", require: "sidekiq-scheduler/web"
gem "sidekiq-unique-jobs"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "pry"
  gem "rspec-rails"
  gem "timecop"
end

group :test do
  gem "rspec-its"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "annotate"
  gem "capistrano", require: false
  gem "capistrano3-puma",   require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-rbenv", require: false
  gem "capistrano-sidekiq", require: false
  gem "capistrano-yarn", require: false
  gem "listen", "~> 3.3"

  gem "rubocop", "1.40.0"

  # to decrypt private key during  deploy
  gem "bcrypt_pbkdf"
  gem "ed25519"
end
