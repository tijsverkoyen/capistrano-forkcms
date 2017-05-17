# Capistrano::Forkcms

Fork CMS specific Capistrano tasks

Capistrano ForkCMS - Easy deployment of ForkCMS 5+ apps with Ruby over SSH.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-forkcms'
```

And then execute:

    $ bundle


## Usage

Require the module in your Capfile:

    require "capistrano/forkcms"
    
The plugin comes with two tasks:

* `forkcms:configure:composer`, which will configure the `capistrano/composer` plugin.
* `forkcms:symlink:document_root`, which will link the document_root to the current-folder. 

But you won't need any of them as everything is wired automagically.


## Configuration

Configuration options:

* `:php_bin_custom_path`, this will allow you to configure a custom PHP binary, the fallback is `php`.
  

## How to use with a fresh Fork install

1. Create a Capfile with the content below:

    # Load DSL and set up stages
    require "capistrano/setup"

    # Include default deployment tasks
    require "capistrano/deploy"

    require "capistrano/scm/git"
    install_plugin Capistrano::SCM::Git

    require "capistrano/forkcms"

    # Load custom tasks from `lib/capistrano/tasks` if you have any defined
    Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

2. Create a file called `config/deploy.rb`, with the content below:

    set :application, "$your-application-name"
    set :repo_url, "$your-repo-url"

    set :keep_releases, 3

3. Create a file called `config/deploy/production.rb`, with the content below:

    ... @todo, fix this

4. Create a file called `config/deploy/staging.rb`, with the content below:

    server "$your-server-hostname", user: "sites", roles: %w{app db web}
    set :deploy_to, "$your-path-where-everything-should-be-deployed"
    set :document_root, "$your-document-root"
    

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tijsverkoyen/capistrano-forkcms](https://github.com/tijsverkoyen/capistrano-forkcms).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
