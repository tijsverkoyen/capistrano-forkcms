namespace :forkcms do
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
    desc <<-DESC
      Links the frontend files folders to their shared counterparts. 
      It copies the contents of the git folders to the shared folder so you can add files through git.
    DESC
    task :frontend_files do
      on roles(:web) do
        # get the list of folders in the frontend files
        folders = get_frontend_files_folders()

        # loop the folders
        folders.each do |folder|
          # create the shared folder if it doesn't exist
          execute :mkdir, '-p', "#{shared_path}/files/#{folder}"
          # copy the contents of the release folder to the shared folder, allowing for adding new files through git
          execute :cp, '-r', "#{release_path}/src/Frontend/Files/#{folder}", "#{shared_path}/files/"
          # remove them from the release folder
          execute :rm, '-rf', "#{release_path}/src/Frontend/Files/#{folder}"
          # create a symlink to the shared folder
          execute :ln, '-s', "#{shared_path}/files/#{folder}", "#{release_path}/src/Frontend/Files/#{folder}"
        end
      end
    end

    def get_frontend_files_folders
      return capture("if [ -e #{release_path}/src/Frontend/Files ]; then ls -1 #{release_path}/src/Frontend/Files; fi").split(/\r?\n/)
    end
  end
end
