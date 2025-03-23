# frozen_string_literal: true

class TestController < ApplicationController
  include TestHelper

  def index; end

  def create
    job_type = params[:job_type]

    if valid_type?(job_type)
      job_type.constantize.perform_async(params[:input], params[:item_type])
      flash.notice = I18n.t('notice.job_type_queued', job_type:)
    else
      flash.alert = I18n.t('errors.invalid_job_type')
    end

    redirect_to test_index_url
  end
end
