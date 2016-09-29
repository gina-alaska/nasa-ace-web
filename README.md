# NASA ACE Website

This application is the main landing page and rails application hosting the workspace functionality.

## Requirements

* ruby 2.3.0+
* bundler (gem install bundler)

## Installation

1. Clone the repository and change directory to the cloned repo
    ```
    $ git clone https://github.com/gina-alaska/nasa-ace-web
    $ cd nasa-ace-web
    ```
    
2. Update dependencies and database schema
    ```
    $ bundle
    $ rake db:migrate
    ```
    
3. Run the server and view in the browser
    ```
    $ rails server
    # open browser and point to url the above command prints.  (Defaults to http://localhost:3000)
    ```
