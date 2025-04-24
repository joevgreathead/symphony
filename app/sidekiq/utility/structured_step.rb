# frozen_string_literal: true

module Utility
  class StructuredStep
    def take(connection)
      # Get it? Take a step
      connection.exec("create temporary table #{table_name} (\n#{table_definitions}\n)")
      connection.exec(insert)
    rescue StandardError => e
      Rails.logger.error(e.message)

      raise
    end

    def insert
      <<-SQL.squish
        insert into #{table_name} (#{table_columns.join(', ')})
        #{raw_sql}
      SQL
    end

    def table_name
      raise NotImplementedError
    end

    def table_columns
      raise NotImplementedError
    end

    def table_definitions
      table_columns.map { |col| "\"#{col}\" varchar not null" }.join(",\n")
    end

    def raw_sql
      raise NotImplementedError
    end
  end
end
