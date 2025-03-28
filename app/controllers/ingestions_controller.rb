# frozen_string_literal: true

class IngestionsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @ingestions = pagy(Ingestion.order(created_at: :desc))
  end
end
