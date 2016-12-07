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

## License

Release under MIT license, see [LICENSE](/LICENSE)

## Contributing

1. Fork the repository on Github
1. Create a named feature branch (like add_component_x)
1. Write you change
1. Write tests for your change (if applicable)
1. Run the tests, ensuring they all pass
1. Submit a Pull Request using Github
