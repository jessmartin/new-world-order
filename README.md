NEW WORLD ORDER
===============

Rails 3 [Relevance][rel] Style.  This means the following:

* Rspec 2 for specs, with focused specs configured out of the box
* Cucumber for user level testing
* JQuery/JQuery-UI for javascript - Protoype/Scriptaculous removed
* Factory Girl for test data
* Mocha installed and configured for mocking inside RSpec
* Simple screen.css with a reset at the top

Getting Started
---------------

First, clone new-world-order locally:

    git clone http://github.com/relevance/new-world-order

Then, generate your new application using the template file:

    rails new my-app -m new-world-order/template.rb

To use your database of choice, use the built in `-d` switch to the `rails` command.  New World Order's generated Gemfile will properly respect your database of choice.  For Postgres, we reach into your database.yml and make the username `postgres` (instead of your application name, which the Rails generator does by default).

    rails new my-postgres-app -d postgresql -m new-world-order/template.rb

NOTE: You _can_ give the rails command a URL for the template, but due to changes in how
Github requires SSL for all urls, and how Net::HTTP verifies SSL in Ruby
1.9+, you now need to clone the template locally first.  Youc an see the
issue here for more info: 

  https://github.com/relevance/new-world-order/issues#issue/5

Feedback and Other Items
------------------------
* Check out the TODO list for our ideas
* Use Github [issues][issues] for bugs

[rel]: http://thinkrelevance.com "Relevance home page"
[issues]: http://github.com/relevance/new-world-order/issues
