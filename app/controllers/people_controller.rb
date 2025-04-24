# frozen_string_literal: true

class PeopleController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @people = pagy(Person.order(created_at: :desc))
  end
end
