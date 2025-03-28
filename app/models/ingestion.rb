# frozen_string_literal: true

class Ingestion < ApplicationRecord
  include AASM

  validates :file_name, presence: true

  has_many :validation_errors, dependent: :destroy

  aasm column: :state do
    state :pending, initial: true
    state :ingesting
    state :ingested
    state :ingestion_failed
    state :transforming
    state :transformed
    state :transformation_failed
    state :exporting
    state :exported
    state :export_failed
    state :completed

    event :begin_ingest do
      transitions from: :pending, to: :ingesting
    end
    event :fail_ingest do
      transitions from: :pending, to: :ingestion_failed
      transitions from: :ingesting, to: :ingestion_failed
    end
    event :complete_ingest do
      after { update(ingested_at: Time.zone.now) }
      transitions from: :ingesting, to: :ingested
    end
  end
end
