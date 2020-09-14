require 'spec_helper'

describe Pod::Downloader::Http do

  describe "#download!" do

    before(:each) do
      Pod::Downloader.azure_base_urls = ["https://pkgs.dev.azure.com"]
    end

    context 'when not downloading a pod from one of the configured base urls' do
      it 'calls #aliased_download!' do
        downloader = Pod::Downloader::Http.new("/tmp", "https://www.microsoft.com", {})

        downloader.target_path.stubs(:mkpath)
        downloader.expects(:aliased_download!)
        downloader.download
      end
    end

    context 'when downloading a pod from one of the configured base urls' do
      it 'can download universal packages from organization feeds' do
        downloader = Pod::Downloader::Http.new("/tmp", "https://pkgs.dev.azure.com/test_org/_apis/packaging/feeds/org_feed/upack/packages/test_package/versions/1.2.3", {})
        parameters = [
          'artifacts',
          'universal',
          'download',
          '--organization', 'https://pkgs.dev.azure.com/test_org/',
          '--feed', 'org_feed',
          '--name', 'test_package',
          '--version', '1.2.3',
          '--path', '/tmp'
        ]

        downloader.target_path.stubs(:mkpath)
        downloader.expects(:execute_command).with('az', parameters, anything)
        downloader.download
      end

      it 'can download universal packages from project feeds' do
        downloader = Pod::Downloader::Http.new("/tmp", "https://pkgs.dev.azure.com/test_org/test_project/_apis/packaging/feeds/project_feed/upack/packages/test_package/versions/1.2.3", {})
        parameters = [
          'artifacts',
          'universal',
          'download',
          '--organization', 'https://pkgs.dev.azure.com/test_org/',
          '--feed', 'project_feed',
          '--name', 'test_package',
          '--version', '1.2.3',
          '--path', '/tmp',
          '--project', 'test_project',
          '--scope', 'project'
        ]

        downloader.target_path.stubs(:mkpath)
        downloader.expects(:execute_command).with('az', parameters, anything)
        downloader.download
      end
    end

  end

end
