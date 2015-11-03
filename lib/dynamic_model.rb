module Dynamicloud
  class API
    # This class represents a Model in <b>Dynamicloud</b>.
    # @author Eleazar Gomez
    # @version 1.0.0
    # @since 8/25/15
    class Model
      class RecordModel
        attr_accessor(:id, :name, :description)

        # Constructs a model using its ID with Mapper
        # @param id model id
        def initialize(id)
          @id = id
          @name = nil
          @description = nil
        end
      end

      # Indicates the different field's types in DynamiCloud
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 9/2/15
      class RecordFieldType
        # Build the enum
        # @param type type value
        def initialize(type)
          @type = type
        end

        TEXT = RecordFieldType.new(1)
        NUMBER = RecordFieldType.new(10)
        CHECKBOX = RecordFieldType.new(2)
        RADIO_BUTTON = RecordFieldType.new(3)
        SELECT = RecordFieldType.new(4)
        SELECT_MULTI_SELECTION = RecordFieldType.new(5)
        TEXTAREA = RecordFieldType.new(6)
        BIG_TEXT = RecordFieldType.new(7)
        PASSWORD = RecordFieldType.new(8)
        DATE = RecordFieldType.new(9)

        # Gets the FieldType according type parameter
        # @param type target
        # @return RecordTypeField
        def self.get_field_type(type)
          case type
            when 1
              TEXT
            when 2
              CHECKBOX
            when 3
              RADIO_BUTTON
            when 4
              SELECT
            when 5
              SELECT_MULTI_SELECTION
            when 6
              TEXTAREA
            when 7
              BIG_TEXT
            when 8
              PASSWORD
            when 9
              DATE
            else
              NUMBER
          end
        end
      end

      # Represents the field's items
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 9/3/15
      class RecordFieldItem
        attr_accessor(:value, :text)

        def initialize
          @value = ''
          @text = ''
        end
      end

      # Represents a field in Dynamicloud.
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 9/2/15
      class RecordField
        attr_accessor(:id, :identifier, :label, :comment, :uniqueness, :required, :type, :items, :mid)

        def initialize
          @id = -1
          @identifier = nil
          @label = nil
          @comment = nil
          @uniqueness = false
          @required = false
          @type = nil
          @items = nil
          @mid = -1
        end
      end
    end
  end
end