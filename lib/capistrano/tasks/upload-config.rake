namespace :config do

  desc 'Initialize local configuration files for each stage'
  task :init do
    run_locally do
      fetch(:upload_config_files).each do |config|
        local_path = CapistranoUploadConfig::Helpers.get_local_upload_config_name(config, fetch(:stage).to_s)
        if File.exists?(local_path)
          warn "Already Exists: #{local_path}"
        else
          example_suffix = fetch(:upload_config_example_suffix, '')
          if File.exists?("#{config}#{example_suffix}")
            FileUtils.cp "#{config}#{example_suffix}", local_path
            info "Copied: #{config}#{example_suffix} to #{local_path}"
          else
            File.open(local_path, "w") {}
            info "Created: #{local_path} as empty file"
          end
        end
      end
    end
  end

  desc 'Check local configuration files for each stage'
  task :check do
    run_locally do
      fetch(:upload_config_files).each do |config|
        local_path = CapistranoUploadConfig::Helpers.get_local_upload_config_name(config, fetch(:stage).to_s)
        if File.exists?(local_path)
          info "Found: #{local_path}"
        else
          warn "Not found: #{local_path}"
        end
      end
    end
  end

  desc 'Push configuration to the remote server'
  task :push do
    on release_roles :all do
      within shared_path do
        fetch(:upload_config_files).each do |config|
          local_path = CapistranoUploadConfig::Helpers.get_local_upload_config_name(config, fetch(:stage).to_s)
          if File.exists?(local_path)
            info "Uploading config #{local_path} as #{config}"
            upload! StringIO.new(IO.read(local_path)), File.join(shared_path, config)
          else
            fail "#{local_path} doesn't exist"
          end
        end
      end
    end
  end

end

namespace :load do
  task :defaults do

    set :upload_config_files, -> { fetch(:linked_files) }
    set :upload_config_example_suffix, '-example'
    # https://github.com/rjocoleman/capistrano-upload-config/issues/1
    set :upload_config_example_prefix, -> { fetch(:upload_config_example_suffix) }

  end
end
