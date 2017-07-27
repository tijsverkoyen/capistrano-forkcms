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
  end
end
