# frozen_string_literal: true

module ItemType
  PERSON = 'person'
  PLACE = 'place'
  THING = 'thing'

  TYPES = [
    PERSON,
    PLACE,
    THING
  ].freeze

  class << self
    def valid_field?(value)
      value.present?
    end

    def validate(accessor_proc, item_type)
      VALIDATIONS[item_type].reject do |field_hash|
        field, validator = ItemType::FIELD_DEFAULT.merge(field_hash).values_at(:field, :validator)

        validator.call(accessor_proc.call(field))
      end
    end
  end

  DEFAULT_VALIDATION = ->(value) { valid_field?(value) }
  FIELD_DEFAULT = { validator: DEFAULT_VALIDATION }.freeze

  PERSON_VALIDATIONS = [
    {
      field: :first,
      message: 'First name can\'t be blank'
    },
    {
      field: :last,
      message: 'Last name can\'t be blank'
    },
    {
      field: :email,
      message: 'Email can\'t be blank'
    },
    {
      field: :email,
      validator: ->(value) { value.blank? || value.include?('@') },
      message: 'Email must be in valid format'
    },
    {
      field: :phone,
      message: 'Phone can\'t be blank'
    }
  ].freeze

  VALIDATIONS = {
    PERSON => PERSON_VALIDATIONS
  }.freeze
end
