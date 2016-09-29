# NASA ACE Website

This application is the main landing page and rails application hosting the workspace functionality.

## Requirements

* ruby 2.3.0+
* bundler (gem install bundler)

## Installation

1. Clone the repository
```
$ git clone REPO_URL
```
2. Change directory to the application
```
$ cd nasa-ace-web
```
3. Update dependencies and data schema
```
$ bundle
$ rake db:migrate
```
4. Run the server and view in the browser
```
$ rails server
# open browser and point to url the above command prints.  (Defaults to http://localhost:3000)
```
