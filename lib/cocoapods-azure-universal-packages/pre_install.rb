module CocoapodsAzureUniversalPackages
  class << self

    Pod::HooksManager.register('cocoapods-azure-universal-packages', :pre_install) do |context, options|
      CocoapodsAzureUniversalPackages.pre_install(options)
    end

    def pre_install(options)
      # Check if the Azure CLI is installed
      raise Pod::Informative, 'Unable to locate the Azure CLI. To learn more refer to https://aka.ms/azcli' unless Pod::Executable.which('az')

      # Install the azure-devops extension if necessary
      Pod::Executable.execute_command('az', ['extension', 'add', '--yes', '--name', 'azure-devops'], false)

      # Optionally, update the azure-devops extension
      if options.fetch(:update_cli_extension, false)
        Pod::Executable.execute_command('az', ['extension', 'update', '--name', 'azure-devops'], false)
      end

      # Now we can configure the downloader to use the Azure CLI for downloading pods from the given hosts
      azure_base_urls = options[:base_url] || options[:base_urls]
      raise Pod::Informative, 'You must configure at least one Azure base url' unless azure_base_urls

      Pod::Downloader.azure_base_urls = ([] << azure_base_urls).flatten.map { |url| url.delete_suffix('/') }
      raise Pod::Informative, 'You must configure at least one Azure base url' if Pod::Downloader.azure_base_urls.empty?
    end

  end
end
