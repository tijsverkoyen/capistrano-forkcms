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

  namespace :symlink do
    desc <<-DESC
      Links the document root to the current folder
      The document root is the folder that the webserver will serve, it should link to the current path.
    DESC
    task :document_root do
      on roles(:web) do
        if test("[ -L #{fetch :document_root} ]") && capture("readlink -- #{fetch :document_root}") == "#{current_path}/"
          # all is well, the symlink is correct
        elsif test("[ -d #{fetch :document_root} ]") || test("[ -f #{fetch :document_root} ]")
          error "Document root #{fetch :document_root} already exists."
          error 'To link it, issue the following command:'
          error "ln -sf #{current_path}/ #{fetch :document_root}"
        else
          execute :mkdir, '-p', File.dirname(fetch(:document_root))
          execute :ln, '-sf', "#{current_path}/", fetch(:document_root)
        end
      end
    end
  end
end
