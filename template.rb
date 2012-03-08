RVM_RUBY = "ruby-1.9.3"
RVM_GEMSET = app_name

def rvm_run(command, config = {})
  run "rvm #{RVM_RUBY}@#{RVM_GEMSET} exec #{command}", config
end

git :init
append_file ".gitignore", "config/database.yml\n"
git :add => "."
git :commit => "-a -m 'Initial commit'"

run 'rm README*'
run 'rm doc/README_FOR_APP'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm -rf test'
run 'rm Gemfile'
run 'rm app/assets/images/rails.png'

create_file 'README.markdown', <<-EOL
# #{app_name}

## Getting Started

    gem install bundler
    # TODO other setup commands here
EOL

run "rm -rf app/views/layouts/application.html.erb"
create_file 'app/views/layouts/application.html.haml', <<EOC
!!!
%html
  %head
    %title #{app_name}
  = stylesheet_link_tag :application
  = javascript_include_tag :application
  = csrf_meta_tag
  %body
    = yield
EOC

commit_message =<<EOC
Remove Rails default files:

  - Add a README template to help devs get started
  - Replace base erb layout with haml layout
EOC
git :add => "."
git :commit => "-m '#{commit_message}'"

# Rails default generator uses 'app_name' as the username for postgresql -- that is dumb
# We replace that with 'postgres' which is a more common development configuration
if options[:database] == "postgresql"
  gsub_file 'config/database.yml', "username: #{app_name}", "username: postgres"
  git :commit => "-a -m 'Use postgres user for database.yml'"
end

run 'cp config/database.yml config/database.example.yml' unless options[:skip_activerecord]

git :commit => "-a -m 'Create a database.example.yml'"

create_file 'Gemfile', <<-CODE
source :rubygems

gem 'rails', '3.2.2'
CODE

gem gem_for_database unless options[:skip_activerecord]

append_file 'Gemfile', <<-CODE
\n
gem 'haml', '3.1.4'
gem 'configatron', '2.9.0'
gem 'airbrake', '~> 3.0.9'
gem 'factory_girl_rails', '1.7.0'
gem 'jquery-rails', '2.0.1'

# Gems used only for assets and not required
# in production environments by default.
group "assets" do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group "development" do
  gem 'pry'
end

group "development", "test" do
  gem 'capybara', '~> 1.1.1'
  gem 'selenium-webdriver', '~> 2.5.0'
  gem 'rspec-rails', '~> 2.8.1'
  gem 'mocha', '~> 0.10.5'
  gem 'guard-rspec',    '~> 0.6.0', :require => false
  gem 'guard-cucumber', '~> 0.7.5', :require => false
  gem 'growl',          '~> 1.0.3', :require => false
  gem 'rb-fsevent',     '~> 0.9.0', :require => false
  gem 'cucumber-rails', '~> 1.3.0', :require => false
end
CODE

create_file ".rvmrc", "rvm #{RVM_RUBY}@#{RVM_GEMSET}"

run "rvm #{RVM_RUBY} gemset create #{RVM_GEMSET}"
rvm_run "gem install bundler"
rvm_run "bundle install"
git :add => "."
git :commit => "-a -m  'Set up initial gems'"

rvm_run "rake db:create:all db:migrate"
git :add => "."
git :commit => "-a -m  'Create local database schema'"

rvm_run "./script/rails generate rspec:install"
run "rm -rf spec"
create_file 'spec/spec_helper.rb', <<-CODE
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :disabled => true
  config.color_enabled = true
end
CODE

git :add => "."
git :commit => "-a -m  'Install rspec'"

append_file 'Rakefile', <<-CODE
Rake::Task[:default].clear
task :default => [:spec]
CODE

git :commit => "-a -m  'Set up default rake task'"

create_file 'config/initializers/pry.rb', <<-CODE
#{app_name.humanize.titleize.gsub(/ /, '')}::Application.configure do
  # Use Pry instead of IRB
  silence_warnings do
    begin
      require 'pry'
      IRB = Pry
    rescue LoadError
    end
  end
end
CODE

git :add => "."
git :commit => "-a -m  'Set up pry for rails console'"
