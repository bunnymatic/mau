# Mission Artists Website

We are striving to provide a simple easy to use platform for Artists to upload their portfolio and share it with the world.

## Developers

Wanna run MAU?  Here's how (rules here assume MacOSX)

Get the source code 

    cd /my_projects/  # Directory under which you want the mau source code to sit
    git clone git@github.com:bunnymatic/mau.git

This will generate a `mau` directory for you.

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

Assuming MySQL is running, and you know have a root-level user, update your `config/database.yml` development section and test section to use that user password (unless your mysql user is `root` with no password).

Install the MAU bundle

    cd /my_projects/mau
    bundle

Tell Rails to build you an empty database

    rake db:create

Tell Rails to setup that database and build a copy of that schema for testing

    rake db:migrate db:test:prepare

At this point, you should have a semi-working system that has no users and no art.  To try it out, start up the server

    script/server

Point your browser to http://localhost:3000 and you should see the MAU front page.

To grab some test data, I've put a snapshot of our developer database on Dropbox.  If you don't already have a link, let me know and I'll share the folder with you.  It's called `/MAU Developer Database` and in this folder is a bundled database and image set.  Download the file.  Then run our database restore task:

    rake rosie:restore datafile=/the/file/you/just/downloaded/mau_development_blah.tgz

This should put in place a bunch of images and update your database content.  Run migrations again to make sure that you're up to date.

    rake db:migrate

You might also run this rake task

    rake mau:reset_passwords

which sets all the user passwords for the system to 'bmatic'.

Restart your server and take another look at http://localhost:3000/.  At this point you should see some artists and stuff.


# Cloud Resources Used

* Github:  https://github.com/bunnymatic/mau Source Code Revision Control
* PostmarkApp: http://postmarkapp.com for transactional email sending
* Site5 for hosting
* NewRelic for app performance analytics/monitoring
* Google Analytics for web analytics
