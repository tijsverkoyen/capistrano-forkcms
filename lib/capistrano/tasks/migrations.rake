namespace :forkcms do
  namespace :migrations do
    desc 'Prepare the server for running Fork CMS migrations'
    task :prepare do
      on roles(:web) do
        create_migrations_file
      end
    end

    desc 'Execute pending migrations'
    task :execute do
      on roles(:web) do
        # Prepare for migrations if it's not done already
        Rake::Task["forkcms:migrations:prepare"].invoke()

        # Abort if no migrations are found
        migration_folders = get_migration_folders
        next if migration_folders.length == 0

        migrations_to_execute = get_migrations_to_execute

        # Abort if no new migrations are found
        next if migrations_to_execute.length == 0

        # As migrations can take a while we show a maintenance page
        Rake::Task["forkcms:maintenance:enable"].invoke()

        # Back up the database, just in case
        Rake::Task["forkcms:database:backup"].invoke()

        # Execute all migrations
        migrations_to_execute.each do |dirname|
          migration_path = "#{release_path}/migrations/#{dirname}"
          migration_files = capture("ls -1 #{migration_path}").split(/\r?\n/)

          migration_files.each do |filename|
            # Execute a MySQL file
            if filename.index('update.sql') != nil
              Rake::Task["forkcms:database:execute"].invoke("#{migration_path}/#{filename}")

              next
            end

            # Update the locale through the console command
            if filename.index('locale.xml') != nil
              execute :php, "#{release_path}/bin/console forkcms:locale:import -f #{migration_path}/#{filename} --env=prod"

              next
            end
          end
        end

        # All migrations were executed successfully and we didn't roll back so put them in the executed_migrations file
        migrations_to_execute.each do |dirname|
          execute :echo , "#{dirname} | tee -a #{shared_path}/executed_migrations"
        end

        # Disable maintenance mode, everything is done
        Rake::Task["forkcms:maintenance:disable"].invoke()
      end
    end

    desc 'Rollback the migrations'
    task :rollback do
      # Restore the database backup so we undo any executed migrations
      Rake::Task["forkcms:database:restore"].invoke()

      # Disable the maintenance page so the site is accessible again
      Rake::Task["forkcms:maintenance:disable"].invoke()
    end

    private

    # Creates a migration file to hold our executed migrations
    def create_migrations_file
      # Stop if the migrations file exists
      return if test "[[ -f #{shared_path}/executed_migrations ]]"

      # Create an empty executed_migrations file
      upload! StringIO.new(''), "#{shared_path}/executed_migrations"

      # If we just created the executed_migrations file, add all existing migrations
      execute_initial_migration
    end

    # Put all items in the migrations folder in the executed_migrations file
    def execute_initial_migration
      migration_folders = get_migration_folders

      migration_folders.each do |dirname|
        run "echo #{dirname} | tee -a #{shared_path}/executed_migrations"
      end
    end

    # Gets the new migrations to execute
    def get_migrations_to_execute
      executed_migrations = capture("cat #{shared_path}/executed_migrations").chomp.split(/\r?\n/)
      migrations_to_execute = Array.new
      migration_folders = get_migration_folders

      # Fetch all migration directories that aren't executed yet
      migration_folders.each do |dirname|
        if executed_migrations.index(dirname) == nil
          migrations_to_execute.push(dirname) 
        end
      end

      return migrations_to_execute
    end

    def get_migration_folders
      return capture("if [ -e #{release_path}/migrations ]; then ls -1 #{release_path}/migrations; fi").split(/\r?\n/)
    end
  end
end
