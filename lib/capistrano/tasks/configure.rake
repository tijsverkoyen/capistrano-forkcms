namespace :forkcms do
  namespace :configure do
    desc <<-DESC
      Configures composer
      It make sure the command is mapped correctly and the correct flags are used.
    DESC
    task :composer do
      # Set the correct composer flags
      set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader --no-scripts'

      # Set the correct bin
      SSHKit.config.command_map[:composer] = "#{fetch :php_bin_path} #{fetch :deploy_to}/shared/composer.phar"
    end

    desc <<-DESC
      Configures cachetool
      It make sure the command is mapped correctly and the correct flags are used.
    DESC
    task :cachetool do
      # Set the correct bin
      SSHKit.config.command_map[:cachetool] = "#{fetch :php_bin_path} #{fetch :deploy_to}/shared/cachetool.phar"
    end
  end
end
