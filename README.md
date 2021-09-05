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

    brew install markdown imagemagick memcached elasticsearch@6

At this point, you should have all the binary resources you'll need (hopefully).

Let's get started:

### MAU setup

Get the source code

    cd /my_projects/  # Directory under which you want the mau source code to sit
    git clone https://github.com/bunnymatic/mau.git

This will generate a `mau` directory for you.


Assuming MySQL is running, and you know have a root-level user, update your `config/database.yml` development section and test section to use that user password (unless your mysql user is `root` with no password).

Install the MAU bundle (or, starting a dev session every time)

    cd /my_projects/mau
    git checkout master
    git pull
    bundle install

Tell Rails to build you an empty database

    rake db:create:all # only if you cloned the repo

Tell Rails to setup that database and build a copy of that schema for testing

    rake db:migrate db:test:prepare

At this point, you should have a semi-working system that has no users and no art.  To try it out, start up the server

    rails server # if you're past that

Point your browser to http://localhost:3000 and you should see the MAU front page.

You might also run this rake task

    rake mau:reset_passwords

which sets all the user passwords for the system to 'bmatic'.

Restart your server and take another look at http://localhost:3000/.  At this point you should see some artists and stuff.

### Virtual Open Studios setup

The Virtual Open Studios Catalog can be accessed at the subdomain `openstudios`. In order to point to this location locally you'll have to update your `/etc/hosts` file.

Run `sudo vim /etc/hosts` to open up the file and add

```
# mau subdomains
127.0.0.1 mau.local
127.0.0.1 openstudios.mau.local
```

Now, we have to tell Rails that we'll be accessing the dev server with the domain name `mau.local`.

Run `rails s -p 3000 -b mau.local` and in your browser go to `mau.local:3000` for the Mission Artists site and `openstudios.mau.local:3000` for the Open Studios site.

### Running the test suite

Once you think things are running, you can try running the test suite:

    rake

## Development

### Testing

We use RSpec and Cucumber.  We have some test code that will auto start Elasticsearch on port 9250.

You shouldn't need to do anything to get things rolling.  Tests that need elastic search know they do and they will start up a server for testing.

In the interest of speed, they do *not* shut that instance down.   Occasionally, after coming back to development, that instance can get in a bad state.  If you run into errors like
```
[500] {"error":{"root_cause":[{"type":"remote_transport_exception","reason":"[node-1][127.0.0.1:9300][indices:data/write/bulk[s][p]]"}],"type":"no_such_file_exception","reason":"/private/tmp/elasticsearch_test/nodes/0/indices/TBNYEDCzRuOAzbcsl98B8g/3/index/write.lock"},"status":500} (Elasticsearch::Transport::Transport::Errors::InternalServerError)
```
it is likely that the instance has gotten into an error state.  The fix is to manually shut down Elasticsearch (the test instance) and let the tests start it up again.  That goes something like

```
# find the elasticsearch process running on port 9250
% ps -ef | grep elasticsearch | grep 9250
  501 32640     1   0  4:14PM ttys002    0:00.00 sh -c elasticsearch -E cluster.name=elasticsearch-test-kinda -E node.name=node-1 -E http.port=9250 ...
  501 32641 32640   0  4:14PM ttys002    1:02.36 /usr/local/opt/openjdk@8/libexec/openjdk.jdk/Contents/Home/bin/java -Xms1g -Xmx1g -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 ...

# kill the two ES processes
% kill -TERM 32640 32641
```


### React

As we move to React (from angular/jquery), here is the way to add a new component.

* Add a component file in `webpack/reactjs/components`
* When the component is ready and tested, if it will be mounted by Rails with `react_component`, add it to the registry (`webpack/reactjs/components/index.js`).  This file will compartmentalize the imports of the components that Rails needs to know about.  Testing should use `react-testing-library` which is already installed.  Test files can sit next the component and should be suffixed with `.test.ts` or `.test.tsx` as appropriate
* Add it to a view using `react_component` helper
```
 = react_component(id: "the-dom-tag-id", component: "MyNewComponent", props: { whatever: "props you need" })
```
* If you need styles, add a scss file under `stylesheets/gto/components/ with the same name as the component, then add that import to `stylesheets/gto/components/index.scss` (we don't have scss globs setup)
* If it's shareable, add it to the `react_styleguide.slim` page under `/admin/tests/`

We have a simple `scaffold` task that can help to get things rolling faster and to help keep us consistent.

```
rails g react_component ComponentName
```

Will create the `ComponentName.tsx` file and it's corresponding test file in the `reactjs/components` directory.

If you plan to use this component in a slim file and want it to be automounted, don't froget to add it to
the `reactjs/components/index.ts` so it'll be in the registry used by the `react_component` rails helper.

### Webpack

We've moved off sprockets and are using webpack exclusively.

During development you can run
```
rails server
```
by itself and everything should work.  But webpack file changes will get recompiled between each change which makes for slow frontend feedback.

To speed this up, in another terminal, use
```
bin/webpack-dev-server
```
and this will give you the dev server which will push incremental changes as you change front-end concerns.


### browser suppoort


We keep track of the supported list in `app/assets/stylesheets/.browserlistrc`.   This is used by
`autoprefixer-rails`.  We also have a `supported_browser?` method which is reading a local list
of browsers which should use the same rules.

To generate a new `browsers.json` file, run

```bash
yarn install
BROWSERSLIST_CONFIG=./app/assets/stylesheets/.browserslistrc bin/get-browserlist.js
```


### Branching/Dev flow
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

NOTE: We only have `master`.  There is no `development` branch any more.  All feature branches should branch off `master`.

# Deployment

We're using capistrano for deployment to Linode servers.  You probably need your keys setup so
at first this might not work.  If you should have permission to deploy, tell Jon and he can
help get the keys setup properly.

Once you have keys

```
cap acceptance deploy
cap production deploy
```

will push the `main` branches respectively to the `mau.rcode5.com` or `www`.

We're using tags to keep track of what's where so here is a little deploy
checklist.

```

# tag the release
git checkout main
git pull
git tag acceptance_deploy_<YYYYmmdd>

# deploy
cap acceptance deploy

# kick over the server
ssh root@mau.rcode5.com

service puma stop
service nginx restart
service puma start

exit

# if it all worked
git push --tags

# And add a note in #deploys channel in slack
```

# Issues/Versions etc

# Keys for external connections

You'll need to create a `config/config.keys.yml` file - use config.keys.yml.example as a starting point.

# Cloud Resources Used

* Github:  https://github.com/bunnymatic/mau Source Code Revision Control
* PostmarkApp: http://postmarkapp.com for transactional email sending
* Linode for hosting
* NewRelic for app performance analytics/monitoring
* Google Analytics for web analytics
* Facebook App - '1568875043351573',
* Google Maps - keys under rcode5 google accounts
* Google ReCaptcha - key under bunnymatic google account - should be moved
