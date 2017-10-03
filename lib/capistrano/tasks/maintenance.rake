namespace :forkcms do
  namespace :maintenance do
    desc 'Enable maintenance mode'
    task :enable do
      on roles(:web) do
        create_maintenance_folder
        execute :rm, '-rf', "#{fetch :document_root} && ln -sf #{shared_path}/maintenance #{fetch :document_root}"
      end
    end

    desc 'Disable maintenance mode'
    task :disable do
      on roles(:web) do
        execute :rm, '-rf', "#{fetch :document_root} && ln -sf #{current_path} #{fetch :document_root}"
      end
    end

    private
    # Creates the maintenance folder based on the local maintenance folder to display when migrating
    def create_maintenance_folder
      # Check if the maintenance folder exists.
      maintenanceFolderExists = capture("if [ -d #{shared_path}/maintenance ]; then echo 'yes'; fi").chomp

      # Stop if the maintenance folder exists
      if maintenanceFolderExists == 'yes'
        return
      end

      local_maintenance_path = File.dirname(__FILE__)
      local_maintenance_path = "#{local_maintenance_path}/../../maintenance"

      # Create a maintenance folder containing the index page from our gem
      execute :mkdir, "#{shared_path}/maintenance"

      # copy the contents of the index.html file to our shared folder
      upload! File.open(local_maintenance_path + '/index.html'), "#{shared_path}/maintenance/index.html"

      # copy the contents of the .htaccess file to our shared folder
      upload! File.open(local_maintenance_path + '/.htaccess'), "#{shared_path}/maintenance/.htaccess"
    end
  end
end
