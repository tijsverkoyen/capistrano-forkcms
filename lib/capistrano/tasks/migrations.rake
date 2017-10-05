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

        # If the current symlink doesn't exist yet, execute the first migration
        execute_initial_migration if not test "[[ -e #{current_path} ]]"

        # Abort if no migrations are found
        migration_folders = get_migration_folders
        if migration_folders.length == 0
          next
        end

        migrations_to_execute = get_migrations_to_execute

        # Abort if no new migrations are found
        if migrations_to_execute.length == 0
          next
        end

        # This can take a while and can go wrong. let's show a maintenance page
        Rake::Task["forkcms:maintenance:enable"].invoke()

        # Back up the database, just in case
        Rake::Task["forkcms:database:backup"].invoke()

        # Execute all migrations
        migrations_to_execute.each do |dirname|
          migration_path = "#{release_path}/migrations/#{dirname}"
          migration_files = capture("ls -1 #{migration_path}").split(/\r?\n/)

          migration_files.each do |filename|
            # Update the locale through the console command
            if filename.index('locale.xml') != nil
              execute :php, "#{release_path}/bin/console forkcms:locale:import -f #{migration_path}/#{filename}"

              next
            end

            # Execute a MySQL file
            if filename.index('update.sql') != nil
              Rake::Task["forkcms:database:execute"].invoke("#{migration_path}/#{filename}")

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
    end

    # Put all items in the migrations folder in the executed_migrations file
    # When doing a deploy:setup, we expect the database to already contain
    # The migrations (so a clean copy of the database should be available
    # when doing a setup)
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
