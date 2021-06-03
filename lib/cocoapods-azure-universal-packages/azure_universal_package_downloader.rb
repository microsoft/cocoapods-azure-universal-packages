require 'addressable'
require 'cocoapods'
require 'cocoapods-downloader'

module Pod
  module Downloader

    @azure_organizations = []

    class << self
      attr_accessor :azure_organizations
    end

    class Http

      private

      alias_method :aliased_download!, :download!

      executable :az

      def download!
        # Check if the url matches any known Azure organization
        organization = Downloader.azure_organizations.find { |org| url.to_s.start_with?(org) }

        if organization.nil?
          aliased_download!
        else
          # Parse the url
          organization.delete_suffix!('/')
          aup_uri_template = Addressable::Template.new(
            "#{organization}{/project}/_apis/packaging/feeds/{feed}/upack/packages/{package}/versions/{version}"
          )
          uri = Addressable::URI.parse(url)
          aup_uri_components = aup_uri_template.extract(uri)

          if !aup_uri_components.nil?
            download_azure_universal_package!(aup_uri_components.merge({ 'organization' => organization }))
  
            # Extract the file if it's the only one in the package
            package_files = target_path.glob('*')
            if package_files.count == 1 && package_files.first.file?
              file = package_files.first
              file_type = begin
                case file.to_s
                when /\.zip$/
                  :zip
                when /\.(tgz|tar\.gz)$/
                  :tgz
                when /\.tar$/
                  :tar
                when /\.(tbz|tar\.bz2)$/
                  :tbz
                when /\.(txz|tar\.xz)$/
                  :txz
                when /\.dmg$/
                  :dmg
                end
              end
              extract_with_type(file, file_type) unless file_type.nil?
            end
          else
            aliased_download!
          end
        end
      end

      def download_azure_universal_package!(params)
        ui_sub_action("Downloading #{params['package']} (#{params['version']}) from Azure feed #{params['feed']} (#{[params['organization'], params['project']].compact.join('/')})") do
          parameters = [
            'artifacts',
            'universal',
            'download',
            '--organization', params['organization'],
            '--feed', params['feed'],
            '--name', params['package'],
            '--version', params['version'],
            '--path', target_path.to_s
          ]

          # If it's a project scoped feed, we need to pass a few more arguments
          parameters.push('--project', params['project'], '--scope', 'project') unless params['project'].nil?

          # Fetch the Universal Package
          az! parameters
        end
      end

    end

  end
end
