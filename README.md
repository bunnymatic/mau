# Mission Artists Website

We are striving to provide a simple easy to use platform for Artists to upload their portfolio and share it with the world.

## Developers

Wanna run MAU?  Here's how (rules here assume MacOSX)

### System Setup

Got git? If not get it.

Do you have `homebrew`?  If this command

    which brew

returns something (like `/usr/local/bin/brew`) then you do.  If not, install `homebrew` from here http://brew.sh/ (Installation instructions are at the bottom).

Do you have `mysql`?  If this command

    which mysql

returns something (like `/usr/local/bin/mysql`) then you do.  If not, use `homebrew` to install it.

    brew install mysql

Follow the post-install instructions to get your MySQL server running.  For easy configuration, use a user called `root` with no password.  Though no password may seems scary, no one can access your development machine's MySQL server so you're probably pretty safe.

Use `homebrew` to install the following packages:

    brew install qt phantomjs markdown imagemagick	memcached

At this point, you should have all the binary resources you'll need (hopefully).

Let's get started:

### MAU setup

Get the source code 

    cd /my_projects/  # Directory under which you want the mau source code to sit
    git clone git@github.com:bunnymatic/mau.git

This will generate a `mau` directory for you.


Assuming MySQL is running, and you know have a root-level user, update your `config/database.yml` development section and test section to use that user password (unless your mysql user is `root` with no password).

Install the MAU bundle (or, starting a dev session every time)

    cd /my_projects/mau
    git checkout master (or git checkout rails3 for now)
    git pull
    bundle install

Tell Rails to build you an empty database

    rake db:create:all # only if you cloned the repo

Tell Rails to setup that database and build a copy of that schema for testing

    rake db:migrate db:test:prepare

At this point, you should have a semi-working system that has no users and no art.  To try it out, start up the server

    script/server # if we're still on rails 2
    rails server # if you're past that

Point your browser to http://localhost:3000 and you should see the MAU front page.

To grab some test data, I've put a snapshot of our developer database on Dropbox.  If you don't already have a link, let me know and I'll share the folder with you.  It's called `/MAU Developer Database` and in this folder is a bundled database and image set.  Download the file.  Then run our database restore task:

    rake rosie:restore datafile=/the/file/you/just/downloaded/mau_development_blah.tgz

This should put in place a bunch of images and update your database content.  Run migrations again to make sure that you're up to date.

    rake db:migrate

You might also run this rake task

    rake mau:reset_passwords

which sets all the user passwords for the system to 'bmatic'.

Restart your server and take another look at http://localhost:3000/.  At this point you should see some artists and stuff.

### Running the test suite

Once you think things are running, you can try running the test suite:

    rake


# Git Flow and Committing code

Here is the preferred git flow for adding to the code:

Get on your local master branch

    git checkout master

Make sure you're up to date by pulling

    git pull

Start a branch

    git checkout -b branch-name

Write some code.
Check that you succeeded at the end by running the tests

    rake

Check in your code 

    git status
    git add <files or .>
    git commit

Check out the branching structure

    git lola

Hop to your master branch and merge in the changes

    git checkout master
    git merge --no-ff branch-name

Check out the new branching structure

    git lola

Double check that you have the latest master branch code

    git pull --rebase

Push your changes out

    git push


# Issues/Versions etc

Ran into issues with rubygems version 2.0.7.  It seems that some deprecations have been removed.  Rails 2.3.x has not been updated.  If you have issues that look like

    /Users/jon/.rbenv/versions/1.8.7-p334/lib/ruby/gems/1.8/gems/rails-2.3.18/lib/rails/gem_dependency.rb:21:in `add_frozen_gem_path': undefined method `source_index' for Gem:Module (NoMethodError)
    	from /Users/jon/.rbenv/versions/1.8.7-p334/lib/ruby/gems/1.8/gems/rails-2.3.18/lib/initializer.rb:298:in `add_gem_load_paths'
    	from /Users/jon/.rbenv/versions/1.8.7-p334/lib/ruby/gems/1.8/gems/rails-2.3.18/lib/initializer.rb:132:in `process'
    	from /Users/jon/.rbenv/versions/1.8.7-p334/lib/ruby/gems/1.8/gems/rails-2.3.18/lib/initializer.rb:113:in `send'
    	from /Users/jon/.rbenv/versions/1.8.7-p334/lib/ruby/gems/1.8/gems/rails-2.3.18/lib/initializer.rb:113:in `run'
    	from /projects/mau/config/environment.rb:26
    	from /projects/mau/spec/spec_helper.rb:6:in `require'

you may need to use an older rubygems version.  I've had success with 1.8.25. 

    gem update --system 1.8.25

Hopefully, once we get away from Rails 2.3.x we won't have to worry about this so much.

# Keys for external connections

You'll need to create a `config/config.keys.yml` file - use config.keys.yml.example as a starting point.

# Cloud Resources Used

* Github:  https://github.com/bunnymatic/mau Source Code Revision Control
* PostmarkApp: http://postmarkapp.com for transactional email sending
* Site5 for hosting
* NewRelic for app performance analytics/monitoring
* Google Analytics for web analytics
* Facebook App - '1568875043351573',