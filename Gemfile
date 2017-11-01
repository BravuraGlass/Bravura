source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
# Document uploading
gem 'carrierwave', '1.2.0'
gem 'mini_magick', '4.8.0'
# Google map integration
gem 'gmaps4rails'
gem 'geocoder', '~> 1.4', '>= 1.4.4'

gem "google_url_shortener"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.0'

unless ENV['HOME'] == "/home/ubuntu"
  gem 'pg'
end

gem 'mysql2'
    
gem 'thin'

gem 'deep_cloneable'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'sprockets-rails', '2.3.3'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
# Use sorcery to authenticate and validate users
gem 'sorcery'
#Unobtrusive scripting adapter for jQuery https://github.com/rails/jquery-ujs
gem 'jquery-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13.0'
  gem 'selenium-webdriver'

  # Gem for create SEED from database records
  # NOTE: doc: https://github.com/rroblak/seed_dump
  gem 'seed_dump'
  # Gem for open debug mod in the server of rails
  # NOTE: doc: https://github.com/rweng/pry-rails
  gem 'pry-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
=begin  
  gem 'capistrano'
  gem 'capistrano3-puma'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-bower'
=end  
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "bower-rails", "~> 0.9.2"

# Gem for create QRCodes from urls
# NOTE: doc: https://github.com/whomwah/rqrcode
gem 'rqrcode'

# Gem for generate barcodes
gem 'barby'

# Gem for generate PDF from HTML
# NOTE: doc: https://github.com/mileszs/wicked_pdf
gem 'wicked_pdf'
# Gem for generate PDF from HTML / Libary wicked_pdf
gem 'wkhtmltopdf-binary'
