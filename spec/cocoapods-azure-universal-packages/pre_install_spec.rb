require 'spec_helper'

describe CocoapodsAzureUniversalPackages do

  describe ".pre_install" do

    before(:each) do
      Pod::Downloader.azure_base_urls = []
    end

    context 'when Azure CLI is not installed' do
      let(:options) { {:base_url => "https://dev.azure.com/"} }

      it 'raises an exception' do
        Pod::Executable.expects(:which).with('az').returns(nil)
        expect { CocoapodsAzureUniversalPackages.pre_install(options) }.to raise_error(Pod::Informative, '[!] Unable to locate the Azure CLI. To learn more refer to https://aka.ms/azcli'.red)
      end
    end

    context 'when Azure CLI is installed' do
      let(:base_options) { {:base_url => "https://dev.azure.com/"} }

      before(:each) do
        Pod::Executable.stubs(:which).with('az').returns('az')
      end

      it 'does not raise an exception' do
        Pod::Executable.expects(:which).with('az').returns('az')
        expect { CocoapodsAzureUniversalPackages.pre_install(base_options) }.to_not raise_error
      end

      it 'installs the Azure CLI DevOps extension' do
        Pod::Executable.expects(:execute_command).with('az', ['extension', 'add', '--yes', '--name', 'azure-devops'], false).returns('')
        CocoapodsAzureUniversalPackages.pre_install(base_options)
      end

      context "with 'update_cli_extension' set to true" do
        let(:options) { base_options.merge(update_cli_extension: true) }

        it 'updates the Azure CLI DevOps extension' do
          Pod::Executable.expects(:execute_command).with('az', ['extension', 'add', '--yes', '--name', 'azure-devops'], false).returns('')
          Pod::Executable.expects(:execute_command).with('az', ['extension', 'update', '--name', 'azure-devops'], false).returns('')
          CocoapodsAzureUniversalPackages.pre_install(options)
        end
      end

      %w[base_url base_urls].each do |url_option|
        context "with a string specified in '#{url_option}'" do
          it 'adds the url to the downloader' do
            Pod::Downloader.expects(:azure_base_urls=).with(includes("https://dev.azure.com"))
            Pod::Downloader.stubs(:azure_base_urls).returns(["https://dev.azure.com"])
            CocoapodsAzureUniversalPackages.pre_install({url_option.to_sym => "https://dev.azure.com/"})
          end
        end

        context "with an array specified in '#{url_option}'" do
          it 'adds the url to the downloader' do
            Pod::Downloader.expects(:azure_base_urls=).with(all_of(includes("https://dev.azure.com"), includes("https://pkgs.dev.azure.com")))
            Pod::Downloader.stubs(:azure_base_urls).returns(["https://dev.azure.com", "https://pkgs.dev.azure.com"])
            CocoapodsAzureUniversalPackages.pre_install({url_option.to_sym => ["https://dev.azure.com/", "https://pkgs.dev.azure.com/"]})
          end
        end

        context "with an empty array specified in '#{url_option}'" do
          it 'raises an exception' do
            Pod::Downloader.expects(:azure_base_urls=).with(equals([]))
            Pod::Downloader.stubs(:azure_base_urls).returns([])
            expect { CocoapodsAzureUniversalPackages.pre_install({url_option.to_sym => []}) }.to raise_error(Pod::Informative, '[!] You must configure at least one Azure base url'.red)
          end
        end
      end

      context "without a base url argument" do
        it 'raises an exception' do
          Pod::Downloader.expects(:azure_base_urls=).never
          expect { CocoapodsAzureUniversalPackages.pre_install({}) }.to raise_error(Pod::Informative, '[!] You must configure at least one Azure base url'.red)
        end
      end
    end

  end

end
