module HerokuLogAnalyzer
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :columns, :database_connection, :column_options

    def initialize
      @columns = {
        "request_id" => {name: "request_id", regex: /.*/, indexed: true},
        "host" => {name: "host", regex: /.*/, indexed: false},
        "dyno" => {name: "dyno", regex: /.*/, indexed: false},
        "connect" => {name: "connect", regex: /.*/, indexed: false},
        "fwd" => {name: "fwd", regex: /.*/, indexed: false},
        "service" => {name: "service", regex: /.*/, indexed: false},
        "status" => {name: "status", regex: /.*/, indexed: false},
        "path" => {name: "path", regex: /.*/, indexed: false},
        "bytes" => {name: "bytes", regex: /.*/, indexed: false},
      }

      @column_options = {}
    end
  end
end
