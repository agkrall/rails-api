source "https://rubygems.org"
ruby "2.3.0"

gem 'rails', '~> 5.0.0'
gem 'rack-cors', :require => 'rack/cors'
gem 'jwt'
gem 'puma', '~> 3.4'

platforms :ruby do
  gem 'pg'
end

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
end

group :test do
  gem 'spring'
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers', '~> 3.1'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
