# Set some Capistrano defaults
set :linked_files, []
set :linked_files, -> { ["app/config/parameters.yml"] }
set :linked_dirs, []
set :linked_dirs, -> { ["app/logs", "app/sessions", "src/Frontend/Files"] }


# Run required tasks after the stage
Capistrano::DSL.stages.each do |stage|
  after stage, "forkcms:configure_composer"
end


# Make sure the composer executable is installed
namespace :deploy do
  after :starting, "composer:install_executable"
end


# Load the tasks
load File.expand_path("../../tasks/forkcms.rake", __FILE__)
