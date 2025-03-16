# frozen_string_literal: true

class TestController < ApplicationController
  include TestHelper

  def index; end

  def create
    job_type = params[:job_type]

    unless valid_type?(job_type)
      flash.alert = I18n.t('errors.invalid_job_type')

      redirect_to test_index_url
      return
    end

    job_type.constantize.perform_async(params[:input])
    flash.notice = I18n.t('notice.job_type_queued', job_type:)

    redirect_to test_index_url
  end
end
