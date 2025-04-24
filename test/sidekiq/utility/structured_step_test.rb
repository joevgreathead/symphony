# frozen_string_literal: true

require 'test_helper'

module Utility
  class StructuredStepTest < ActiveSupport::TestCase
    class TestStructuredStep < StructuredStep
      def table_name
        'test_temp_table'
      end

      def table_columns
        %w[name email phone]
      end

      def raw_sql
        <<~SQL.squish
          select
            'Test Person' as name,
            'test@example.com' as email,
            '123-456-7890' as phone
        SQL
      end
    end

    def setup
      @step = TestStructuredStep.new
      @connection = ActiveRecord::Base.connection.raw_connection
    end

    test 'temporary table is created and insert is run' do
      @connection.expects(:exec).with(
        "create temporary table test_temp_table (\n\"name\" varchar not null,\n\"email\" varchar not null,\n\"phone\" varchar not null\n)"
      )
      @connection.expects(:exec).with(
        "insert into test_temp_table [\"name\", \"email\", \"phone\"] values ( select 'Test Person' as name, 'test@example.com' as email, '123-456-7890' as phone )"
      )

      @step.take @connection
    end

    test 'error from the connection is logged and re-raised' do
      @connection.expects(:exec).raises(StandardError.new('This is a test!'))

      assert_raises StandardError, match: 'This is a test!' do
        @step.take @connection
      end
    end
  end
end
