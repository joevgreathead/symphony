# frozen_string_literal: true

class MockConnection
  attr_reader :executions, :put_data, :end_called

  def initialize
    @end_called = false
  end

  def exec(sql_str)
    @executions ||= []
    @executions << sql_str
  end

  def put_copy_data(sql_str)
    @put_data ||= []
    @put_data << sql_str
  end

  def put_copy_end
    @end_called = true
  end

  def method_missing(method, *args); end # rubocop:disable Style/MissingRespondToMissing
end
