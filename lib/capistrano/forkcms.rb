require "capistrano/composer"

namespace :load do
  task :defaults do
    set :php_bin_path, -> {
      php_bin_path = fetch(:php_bin_custom_path)
      php_bin_path ||= "php"
    }

    load "capistrano/forkcms/defaults.rb"
  end
end
