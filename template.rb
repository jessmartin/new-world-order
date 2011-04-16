RVM_RUBY = "ruby-1.9.2"
RVM_GEMSET = app_name

def rvm_run(command, config = {})
  run "rvm #{RVM_RUBY}@#{RVM_GEMSET} exec #{command}", config
end

git :init
append_file '.gitignore', "vendor/bundler_gems\nconfig/database.yml\n"
git :add => "."
git :commit => "-a -m 'Initial commit'"

%W[Gemfile README doc/README_FOR_APP public/index.html public/images/rails.png].each do |path|
  run "rm #{path}"
end

run "rm -rf test"

file 'README.markdown', <<-EOL
# Welcome to #{app_name}

## Summary

#{app_name} is a .... TODO high level summary of app

## Getting Started

    gem install bundler
    # TODO other setup commands here

## Seed Data

## For sass2css run:
    
    sass --watch public/stylesheets/bassline:public/stylesheets

Login as ....  # TODO insert typical test accounts for QA / devs to login to app as
EOL

# clone bassline sass/css into public
run "git clone git@github.com:michaelparenteau/bassline.git public/stylesheets/bassline"
run "rm -rf public/stylesheets/bassline/.git"
run "rm -rf public/stylesheets/bassline/.gitignore"

open("http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js") do |source|
  File.open("public/javascripts/jquery-1.4.2.min.js", 'w') {|f| f.write(source.read) }
end

open("http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.1/jquery-ui.min.js") do |source|
  File.open("public/javascripts/jquery-ui-1.8.1.min.js", 'w') {|f| f.write(source.read) }
end

open("https://github.com/rails/jquery-ujs/raw/master/src/rails.js") do |source|
  File.open("public/javascripts/rails.js", "w") {|f| f.write(source.read) }
end

gsub_file "config/application.rb", /javascript_expansions\[:defaults\] = %w\(/ do |match|
  match << "jquery-1.4.2.min jquery-ui-1.8.1.min rails"
end

run "rm -rf app/views/layouts/application.html.erb"
file 'app/views/layouts/application.html.haml', <<EOC
!!!
%html
  %head
    %title #{app_name}
  = stylesheet_link_tag :all
  = javascript_include_tag :defaults
  = csrf_meta_tag
%body
  = yield
EOC

commit_message =<<EOC
Remove defaults; add preferred JS and CSS; add haml:

  - replace Protoype with jquery & jquery-ui minified versions
  - add bassline sass/css
  - add a README template to help devs get quick started
  - replace base erb layout with haml layout
EOC
git :add => "."
git :commit => "-m '#{commit_message}'"

# Rails default generator uses 'app_name' as the username for postgresql -- that is dumb
# We replace that with 'postgres' which is a more common development configuration
if options[:database] == "postgresql"
  gsub_file 'config/database.yml', "username: #{app_name}", "username: postgres"
  git :commit => "-a -m 'Use postgres user for database.yml'"
end

file 'Gemfile', <<-CODE
source "http://rubygems.org"

gem "rails", "3.0.6"
gem "haml"
CODE

gem gem_for_database unless options[:skip_activerecord]

append_file 'Gemfile', <<-CODE

group "development", "test" do
  gem "rspec", "~> 2.0"
  gem "rspec-rails", "~> 2.0"
end

group "test" do
  gem "database_cleaner"
  gem "capybara"
  gem "cucumber-rails", "0.3.2"
  gem "factory_girl_rails", "1.0", :require => nil
  gem "mocha"
  gem "test-unit"
end
CODE

file ".rvmrc", "rvm use #{RVM_RUBY}@#{RVM_GEMSET}\n"

run "rvm #{RVM_RUBY} gemset create #{RVM_GEMSET}"
rvm_run "gem install bundler"
rvm_run "bundle install"
git :add => "."
git :commit => "-a -m  'Initial gems setup'"

rvm_run "./script/rails generate rspec:install"
gsub_file 'spec/spec_helper.rb', "# config.mock_with :mocha", "config.mock_with :mocha"
gsub_file 'spec/spec_helper.rb', "config.mock_with :rspec", "# config.mock_with :rspec"
rspec_config =<<-CODE
  # Configure RSpec to run focused specs, and also respect the alias 'fit' for focused specs
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true
  # Turn color on if we are NOT inside Textmate, Emacs, or VIM
  config.color_enabled = ENV.keys.none? { |k| k.include?("TM_MODE", "EMACS", "VIM") }
CODE

inject_into_file "spec/spec_helper.rb", rspec_config, :after => /Rspec.configure.*$/

git :add => "."
git :commit => "-a -m 'Rspec generated'"

rvm_run "./script/rails generate cucumber:install --rspec --capybara"
run "cp config/database.yml config/database.example.yml"
git :add => "."
git :commit => "-a -m 'Cucumber generated'"

rvm_run "rake db:create:all db:migrate"

say "All done!  Thanks for installing using the NEW WORLD ORDER"
