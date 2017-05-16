#
# Capistrano defaults
#
set :linked_files, []
set :linked_files, -> { ["app/config/parameters.yml"] }
set :linked_dirs, []
set :linked_dirs, -> { ["app/logs", "app/sessions", "src/Frontend/Files"] }

#
# Capistrano/Composer defaults
#
puts deploy_to

SSHKit.config.command_map[:composer] = "php #{deploy_to}/shared/composer.phar"

set :composer_working_dir, -> { fetch(:release_path) }
set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader --no-scripts'

namespace :deploy do
  after :starting, 'composer:install_executable'
end
