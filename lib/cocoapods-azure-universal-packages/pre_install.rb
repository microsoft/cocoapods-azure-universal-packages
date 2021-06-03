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
      azure_organizations = options[:organization] || options[:organizations]
      raise Pod::Informative, 'You must configure at least one Azure organization' unless azure_organizations

      Pod::Downloader.azure_organizations = ([] << azure_organizations).flatten.map { |url| url.delete_suffix('/') }
      raise Pod::Informative, 'You must configure at least one Azure organization' if Pod::Downloader.azure_organizations.empty?
    end

  end
end
