HADOOP_SERVER_IP='10.0.0.146'
HADOOP_SERVER_PORT=8088

gem 'minitest'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'
require '../hadoopconf/hadoop_conf.rb'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

describe HadoopConfig do
  describe "fetching a hadoop configuration from a remote server" do
    before do
      @valid_params = {
        :server => HADOOP_SERVER_IP,
        :port => HADOOP_SERVER_PORT
      }

      @invalid_params = {
          :server => "hooey",
          :port => "-1"
      }
    end

    it "uses the server hostname and port to construct the server url" do
      t = HadoopConfig.new(@valid_params)
      t.server_url.must_equal "http://#{HADOOP_SERVER_IP}:#{HADOOP_SERVER_PORT}/conf"
    end

    it "respects timeout" do
      t = HadoopConfig.new(@valid_params.merge({ :timeout => 1 }))
      stub_request(:get, t.server_url).to_timeout

      t.fetch.must_equal false
      t.errors.empty?.must_equal false
      t.errors.full_messages[0].must_match /execution expired/
    end

    it "loads the default rule set if not provided" do
      t = HadoopConfig.new(@valid_params)
      t.rules.must_equal t.rules_default
    end

    it "sends a request to non-existent server for config" do
      VCR.use_cassette('fail_to_fetch_hadoop_config') do
        t = HadoopConfig.new(@invalid_params)
        t.fetch.must_equal false
        t.errors.empty?.must_equal false
        t.errors.full_messages[0].must_match /bad hostname/
      end
    end

    it "sends a request to hadoop server for config with default parameters" do
      VCR.use_cassette('fetch_hadoop_config') do
        t = HadoopConfig.new(@valid_params)

        t.fetch.must_equal true
        t.errors.empty?.must_equal true

        # Check default properties sifting
        pr = t.properties
        pr.length.must_be :>, 0
        (pr.select { |p| p['name'] == 'yarn.resourcemanager.scheduler.address' }).length.must_equal 1
        (pr.select { |p| p['name'] == 'yarn.app.mapreduce.am.staging-dir' }).length.must_equal 1
        (pr.select { |p| p['name'] == 'mapreduce.jobhistory.address' }).length.must_equal 1
       end
    end

    it "sends a request to hadoop server for config with custom rules" do
      VCR.use_cassette('fetch_hadoop_config') do
        t = HadoopConfig.new(@valid_params)

        t.fetch.must_equal true
        t.errors.empty?.must_equal true

        # Try getting all that match a certain source
        pr = t.properties([
          { 'property' => 'source',
            'rule'     => '==',
            'value'    => 'mapred-default.xml' }
        ])
        pr.length.must_be :>, 0
        (pr.select { |p| p['source'] == 'mapred-default.xml' }).length.must_equal pr.length

        # Try getting all that don't match a certain source
        pr = t.properties([
          { 'property' => 'source',
            'rule'     => '!=',
            'value'    => 'mapred-default.xml' }
        ])
        pr.length.must_be :>, 0
        (pr.select { |p| p['source'] == 'mapred-default.xml' }).length.must_equal 0
      end
    end
  end
end
