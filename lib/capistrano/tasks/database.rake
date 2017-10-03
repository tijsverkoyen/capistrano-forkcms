namespace :forkcms do
  namespace :database do

    backup_file = 'mysql_backup.sql'

    desc 'Create a backup of the database'
    task :backup do
      on roles(:web) do
        # Fetch our flags to reach the database
        flags = get_mysql_connection_flags

        # Abort if no flags are found
        if flags == nil
          next
        end

        execute :mysqldump, "#{flags} --skip-lock-tables > #{release_path}/#{backup_file}"
      end
    end

    desc 'Restore the database from a backup file'
    task :restore do
      on roles(:web) do
        # Check if the file exists.
        if capture("if [ -f #{release_path}/#{backup_file} ]; then echo 'yes'; fi").chomp != 'yes'
          puts "No backup file found, create a backup first"
          next
        end

        Rake::Task["forkcms:database:execute"].invoke("#{release_path}/#{backup_file}")
      end
    end

    desc 'Execute an SQL file'
    task :execute, [:file] do |t, arguments|
      on roles(:web) do
        # Stop if the file does not exist
        if capture("if [ -f #{arguments[:file]} ]; then echo 'yes'; fi").chomp != 'yes'
          puts "File at #{arguments[:file]} does not exist"
          next        
        end

        # Fetch our flags to reach the database
        flags = get_mysql_connection_flags

        # Abort if no flags are found
        if flags == nil
          next
        end

        # Execute the file
        execute :mysql,"#{flags} < #{arguments[:file]}"
      end
    end

    private
    def get_parameters
      parameter_path = "#{shared_path}/app/config/parameters.yml"
      # Abort if the parameters file doesn't exist
      if capture("if [ -f #{parameter_path} ]; then echo 'yes'; fi").chomp != 'yes'
        puts "parameters.yml not found, it should be at #{parameter_path}"
        return
      end

      # Fetch the content of the parameters
      parameters_content = capture "cat #{parameter_path}"
      # It seems we use invalid yml in our config files
      # Therefore we need to fix some issues with it.
      parameters_content = parameters_content.gsub(/:(\s*)%(.*)/, ':\1"%\2"')

      parameters_content = YAML::load(parameters_content)

      # Return them
      return parameters_content.fetch('parameters')
    end

    def get_mysql_connection_flags
      # Fetch our parameters to reach the database
      parameters = get_parameters

      # Abort if no parameters are found
      if parameters == nil
        return
      end

      # Define our mapping
      mapping = {
          'host' => parameters.fetch('database.host'),
          'port' => parameters.fetch('database.port'),
          'user' => parameters.fetch('database.user'),
          'password' => parameters.fetch('database.password'),
      }

      # Set the default flags
      flags = "--default-character-set='utf8' "

      # Append each mapped property to our flags
      mapping.each do |key, value|
        flags << "--#{key}=#{value} " unless value.nil?
      end

      # Append our database
      database = parameters.fetch('database.name')
      flags << "#{database}"

      return flags
    end
  end
end
