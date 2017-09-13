# Capistrano::Forkcms

Fork CMS specific Capistrano tasks

Capistrano ForkCMS - Easy deployment of ForkCMS 5+ apps with Ruby over SSH.


## Installation

First, we create a Gemfile by executing:

```bash
bundle init
```

Now add this line to this created application's Gemfile:

```ruby
gem 'capistrano-forkcms'
```

And then execute:

```bash
bundle
```

## Usage

We need a `Capfile` in our project.
You can create one by executing:
```bash
cap install
```
> In [How to use with a fresh Fork install](#how-to-use-wth-a-fresh-fork-install) you have to copy/paste the code.

Then require the module in your Capfile:

```
require "capistrano/forkcms"
```
    
The plugin comes with two tasks:

* `forkcms:configure:composer`, which will configure the `capistrano/composer` plugin.
* `forkcms:opcache:reset`, which will reset the opcache.
* `forkcms:symlink:document_root`, which will link the document_root to the current-folder. 

But you won't need any of them as everything is wired automagically.


## Configuration

Configuration options:

* `:php_bin_custom_path`, this will allow you to configure a custom PHP binary, the fallback is `php`.
* `:opcache_reset_strategy`, the reset strategy. Possible options: file, fcgi
* `opcache_reset_fcgi_connection_string`, the fcgi-connection string used for the [cachetool](http://gordalina.github.io/cachetool/).
   required when `:opcache_reset_strategy` is `fcgi`.
* `opcache_reset_base_url`, the public url of your website. Required when `:opcache_reset_strategy` is `file`


## How to use with a fresh Fork install

1. Create a Capfile with the content below:

```
set :deploy_config_path, 'app/config/capistrano/deploy.rb'
set :stage_config_path, 'app/config/capistrano/stages'

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git
require 'capistrano/forkcms'

set :format_options, log_file: 'app/logs/capistrano.log'

Dir.glob('app/config/capistrano/tasks/*.rake').each { |r| import r }
```

2. Create a file called `app/config/capistrano/deploy.rb`, with the content below:

```
set :application, "$your-application-name"
set :repo_url, "$your-repo-url"

set :keep_releases, 3
```
> F.e.: `$your-application-name` can be "website" (this will create a folder `apps/website`) and `$your-repo-url` can be something like `git@github.com:<username>/<repository-name>.git`.

3. Create a file called `app/config/capistrano/stages/production.rb`, with the content below:

```
server "$your-server-hostname", user: "$your-user", roles: %w{app db web}

set :deploy_to, "$your-path-where-everything-should-be-deployed" # eg: /home/johndoe/apps/website
set :document_root, "$your-document-root" # eg: /var/www

set :opcache_reset_strategy, "fcgi"
set :opcache_reset_fcgi_connection_string, "$your-php-fpm-socket-or-connection-string" # eg: /var/run/php_71_fpm_sites.sock

# or if you are not using FCGI/FPM
#set :opcache_reset_strategy, "file"
#set :opcache_reset_base_url, "$your-public-url" # eg: "http://www.fork-cms.com"

### DO NOT EDIT BELOW ###
set :branch, "master"
set :keep_releases, 3
set :php_bin, "php"

SSHKit.config.command_map[:composer] = "#{fetch :php_bin} #{shared_path.join("composer.phar")}"
SSHKit.config.command_map[:php] = fetch(:php_bin)
```

4. Create a file called `app/config/capistrano/stages/staging.rb`, with the content below:

```
server "$your-server-hostname", user: "$your-user", roles: %w{app db web}
set :deploy_to, "$your-path-where-everything-should-be-deployed" # eg: /home/johndoe/apps/website
set :document_root, "$your-document-root" # eg: /var/www

set :opcache_reset_strategy, "fcgi"
set :opcache_reset_fcgi_connection_string, "$your-php-fpm-socket-or-connection-string" # eg: /var/run/php_71_fpm_sites.sock

# or if you are not using FCGI/FPM
#set :opcache_reset_strategy, "file"
#set :opcache_reset_base_url, "$your-public-url" # eg: "http://www.fork-cms.com"

set :branch, "staging"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/tijsverkoyen/capistrano-forkcms](https://github.com/tijsverkoyen/capistrano-forkcms).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).