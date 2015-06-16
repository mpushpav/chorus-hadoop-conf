require 'active_model'
require 'nokogiri'
require 'httparty'
require 'yaml'

class HadoopConfig
  include ActiveModel::Validations

  validates_presence_of :server
  validates_length_of :server, :minimum => 1, :maximum => 255

  ALLOWED_RULE_OPERATORS = {
      '==' => ->(a,b) { a == b },
      '!=' => ->(a,b) { a != b }
  }

  def initialize(h)
    @server = h[:server]
    @port = h[:port]
    @rules = h[:rules] || rules_default
    @timeout = h[:timeout] || 5
  end

  def server_url
    "http://#{@server}" + (@port ? ":#{@port}" : "") + "/conf"
  end

  def fetch
    response = HTTParty.get(server_url, timeout: @timeout)
    @properties = response["configuration"]

    true
  rescue Exception => e
    errors.add(:base, e.message)
    # puts e.backtrace
    false
  end

  def properties(rules=rules)
    rules.each do |rule|
      raise "Invalid rule operator" if ALLOWED_RULE_OPERATORS[rule['rule']].nil?
    end

    # For each rule, adds any property from the original set that passes.
    filtered_results = Set.new
    @properties['property'].each do |p|
      rules.each do |rule|
        if ALLOWED_RULE_OPERATORS[rule['rule']].call(p[rule['property']], rule['value'])
          filtered_results.add(p)
        end
      end
    end

    # Returns sorted by 'name' property.
    filtered_results.to_a.sort_by { |a| a["name"] }
  rescue Exception => e
    errors.add(:base, e.message)
    puts e.backtrace
    nil
  end

  def rules
    @rules
  end

  def rules_default
    rules = YAML.load_file(File.expand_path('../', __FILE__) + '/rules.default.yml')
  rescue Exception => e
    errors.add(:base, e.message)
    # puts e.backtrace
    nil
  end
end