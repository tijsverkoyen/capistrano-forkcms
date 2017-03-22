load File.expand_path('../tasks/fork.rake', __FILE__)

namespace :load do
  task :defaults do
    load "capistrano/forkcms/defaults.rb"
  end
end
