require "capistrano/composer"

namespace :load do
  task :defaults do
    load "capistrano/forkcms/defaults.rb"
  end
end
