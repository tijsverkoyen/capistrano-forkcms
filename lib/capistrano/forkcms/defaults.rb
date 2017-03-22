#
# Capistrano defaults
#
set :linked_files, []
set :linked_files, -> { ["app/config/parameters.yml"] }
set :linked_dirs, []
set :linked_dirs, -> { ["app/logs", "app/sessions", "src/Frontend/Files"] }
