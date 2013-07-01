require "heroku-log-analyzer"

namespace :logdb do
  def init
    @current_columns = HerokuLogAnalyzer::Log.columns_hash.keys
    @data_regex = /(?<key>\S+)=(?<val>\S+)/
    @date_regex = /^(?<date>\S+) (?<drain>\S+) (?<source>[a-zA-Z\[\]\.]+)/
    @columns = HerokuLogAnalyzer.configuration.columns
    @batch = {}
  end

  def prepare_content(data)
    ret = {}
    data.each do |key, val|
      if @columns[key]
        regex = @columns[key][:regex]
        m = regex.match val
        ret[@columns[key][:name]] = m.to_a[-1]
      else
        ret[key] = val
      end
    end
    ret
  end

  def parse_line(line)
    data = Hash[line.scan(@data_regex)]
    data = data.slice *@columns.keys

    return nil if data.blank?

    misc_data = @date_regex.match line
    data.merge Hash[misc_data.names.zip(misc_data.captures)]

    return nil unless data['request_id']

    request_id = data['request_id']

    data = prepare_content(data)

    @batch[request_id] ||= {}
    @batch[request_id].merge! data
    @batch[request_id]["full_text"] ||= ""
    @batch[request_id]["full_text"] += "\n#{line}"
  end

  def process_batch(bang=false)
    return nil if @batch.size < 1000 and not bang
    @batch.each do |request_id, data|
      l = HerokuLogAnalyzer::Log.create data
    end
    @batch = {}
  end

  def process_batch!
    process_batch(bang=true)
  end

  task :parse do

    init
    filename = ENV['file_name']
    unless filename
      puts "you must supply a file_name"
      exit 1
    end
    begin
      File.open(filename, 'r') do |f|
        f.each_line do |line|
          process_batch
          parse_line line
        end
      end
      process_batch!
    end
  end
end
