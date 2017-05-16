namespace :forkcms do
  task :configure_composer do
    # Set the correct composer flags
    set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader --no-scripts'

    # Set the correct bin
    SSHKit.config.command_map[:composer] = "#{fetch :php_bin_path} #{fetch :deploy_to}/shared/composer.phar"
  end
end
