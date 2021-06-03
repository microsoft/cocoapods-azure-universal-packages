require 'spec_helper'

describe Pod::Downloader::Http do

  describe "#download!" do

    before(:each) do
      Pod::Downloader.azure_organizations = ["https://pkgs.dev.azure.com/test_org"]
    end

    context 'when not downloading a pod from one of the configured Azure organizations' do
      it 'calls #aliased_download!' do
        downloader = Pod::Downloader::Http.new("/tmp", "https://www.microsoft.com", {})

        downloader.target_path.stubs(:mkpath)
        downloader.target_path.stubs(:glob).returns([])
        downloader.expects(:aliased_download!)
        downloader.download
      end
    end

    context 'when downloading a pod from one of the configured Azure organizations' do

      [
        "https://dev.azure.com/test_org",
        "https://test_org.azure.com"
      ].each do |org|
        it "can download universal packages from organization feeds with an organization url like #{org}" do
          Pod::Downloader.azure_organizations = [org]
          downloader = Pod::Downloader::Http.new("/tmp", "#{org}/_apis/packaging/feeds/org_feed/upack/packages/test_package/versions/1.2.3", {})
          parameters = [
            'artifacts',
            'universal',
            'download',
            '--organization', org,
            '--feed', 'org_feed',
            '--name', 'test_package',
            '--version', '1.2.3',
            '--path', '/tmp'
          ]
  
          downloader.target_path.stubs(:mkpath)
          downloader.target_path.stubs(:glob).returns([])
          downloader.expects(:execute_command).with('az', parameters, anything)
          downloader.download
        end
  
        it "can download universal packages from project feeds with an organization url like #{org}" do
          Pod::Downloader.azure_organizations = [org]
          downloader = Pod::Downloader::Http.new("/tmp", "#{org}/test_project/_apis/packaging/feeds/project_feed/upack/packages/test_package/versions/1.2.3", {})
          parameters = [
            'artifacts',
            'universal',
            'download',
            '--organization', org,
            '--feed', 'project_feed',
            '--name', 'test_package',
            '--version', '1.2.3',
            '--path', '/tmp',
            '--project', 'test_project',
            '--scope', 'project'
          ]
  
          downloader.target_path.stubs(:mkpath)
          downloader.target_path.stubs(:glob).returns([])
          downloader.expects(:execute_command).with('az', parameters, anything)
          downloader.download
        end
      end
    end

    context 'when downloading a universal package with a single file' do

      [
        [:zip, '.zip'],
        [:tgz, '.tgz'], [:tgz, '.tar.gz'],
        [:tar, '.tar'],
        [:tbz, '.tbz'], [:tbz, '.tar.bz2'],
        [:txz, '.txz'], [:txz, '.tar.xz'],
        [:dmg, '.dmg'],
      ].each do |params|
        it 'extracts the archive ' + params[1] do
          downloader = Pod::Downloader::Http.new("/tmp", "https://pkgs.dev.azure.com/test_org/test_project/_apis/packaging/feeds/project_feed/upack/packages/test_package/versions/1.2.3", {})
          archive = Pathname("/tmp/archive#{params[1]}")
          archive_type = params[0]

          archive.stubs(:file?).returns(true)
          downloader.target_path.stubs(:mkpath)
          downloader.target_path.stubs(:glob).returns([archive])
          downloader.expects(:extract_with_type).with(archive, archive_type)
          downloader.download
        end
      end

      it 'does not extract non archive files' do
        downloader = Pod::Downloader::Http.new("/tmp", "https://pkgs.dev.azure.com/test_org/test_project/_apis/packaging/feeds/project_feed/upack/packages/test_package/versions/1.2.3", {})
        file = Pathname("/tmp/file.txt")

        file.stubs(:file?).returns(true)
        downloader.target_path.stubs(:mkpath)
        downloader.target_path.stubs(:glob).returns([file])
        downloader.expects(:extract_with_type).never
        downloader.download
      end

      it 'does not extract directories' do
        downloader = Pod::Downloader::Http.new("/tmp", "https://pkgs.dev.azure.com/test_org/test_project/_apis/packaging/feeds/project_feed/upack/packages/test_package/versions/1.2.3", {})
        dir = Pathname("/tmp/dir.zip")

        dir.stubs(:file?).returns(false)
        downloader.target_path.stubs(:mkpath)
        downloader.target_path.stubs(:glob).returns([dir])
        downloader.expects(:extract_with_type).never
        downloader.download
      end

    end

  end

end
