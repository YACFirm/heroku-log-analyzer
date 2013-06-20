require "heroku-log-analyzer"


namespace :logdb do
  Log = HerokuLogAnalyzer::Log
  task :create do
    class FakeMigration < ActiveRecord::Migration
      def up
        @table_name = "logs"
        @columns = HerokuLogAnalyzer.configuration.columns
        unless Log.table_exists?
          create_table @table_name do |t|
            t.datetime :date
            t.string :drain
            t.string :source
            t.text :full_text
          end

         add_index(@table_name, [:date], {})
        end

        @columns.each do |k, column_data|
          is_indexed = index_exists?(@table_name, column_data[:name])
          remove_index(@table_name, column_data[:name]) if not column_data[:indexed] and is_indexed
        end

        current_columns = Log.columns_hash.keys
        all_columns = %w|date drain source full_text| + @columns.map {|k, v| v[:name]}

        new_columns = all_columns - current_columns
        unused_columns = current_columns - all_columns

        puts new_columns
        puts unused_columns

        remove_column(@table_name, *unused_columns) unless unused_columns.empty?

        new_columns.each do |column_name|
          column_data = @columns[column_name]
          add_column(@table_name, column_data[:name], :string, {})
        end

        @columns.each do |k, column_data|
          is_indexed = index_exists?(@table_name, column_data[:name])
          add_index(@table_name, column_data[:name], {}) if column_data[:indexed] and not is_indexed
        end
      end
    end

    migration = FakeMigration.new
    migration.up
  end
end
