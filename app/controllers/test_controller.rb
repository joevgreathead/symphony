# frozen_string_literal: true

class TestController < ApplicationController
  def index; end

  def create
    TimeJob.perform_async(params[:input])

    redirect_to test_index_url
  end
end
