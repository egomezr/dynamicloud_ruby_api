require 'dynamicloud/version'

#This module contains all what you need to build criteria, queries, updates, inserts, deletes, etc
module Dynamicloud
  class API
    class Criteria
      class Condition
        #Auxiliar constant to build from condition objects
        ROOT = Condition.new

        WITHOUT = '-'

        #This method will return a of this condition
        #@param parent this is the parent of this condition
        #@return a string
        def to_record_string(parent)
          ''
        end
      end
      # End of Condition class

      class ANDCondition < Condition
        # Will build an and condition using two part.
        # @param left  left part of this and condition
        # @param right right part of this and condition
        def initialize(left, right)
          unless (left.is_a?(Condition)) || (right.is_a?(Condition))
            raise 'left and right should implement Condition'
          end

          @left = left
          @right = right
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          (parent.is_a?(ORCondition) ? '"where": {' : '') + @left.to_record_string(self) + ',' + @right.to_record_string(self) + (parent.is_a?(ORCondition) ? '}' : '')
        end
      end
      # End of ANDCondition class

      class EqualCondition < Condition

        # This constructor will build an equal condition using left and right parts.
        # @param left  left part of this equal condition
        # @param right right part of this equal condition
        def initialize(left, right, greater_lesser = '-')
          @left = left
          @right = right
          @need_quotes = right.is_a? String
          @greater_lesser = greater_lesser
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          if @greater_lesser == '-'
            return '"' + @left.to_s + '" : ' + (@need_quotes ? '"' : '') + @right.to_s + (@need_quotes ? '"' : '');
          end

          '"' + @left.to_s + '" : { ' + (@greater_lesser == '>' ? '"$gte": ' : '"$lte": ') +
              (@need_quotes ? '"' : '') + @right.to_s + (@need_quotes ? '"' : '') + ' }'
        end
      end
      # End of EqualCondition class

      class GreaterLesser < Condition
        def initialize(left, right, greater_lesser)
          @greater_lesser = greater_lesser
          @left = left
          @right = right
          @need_quotes = right.is_a?(String)
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          '"' + @left + '": { ' +
              (@greater_lesser == '>' ? '"$gt"' : '"$lt"') + ': ' +
              (@need_quotes ? '"' : '') + @right.to_s + (@need_quotes ? '"' : '') +
              ' }'
        end
      end
      # End of GreaterLesser class

      # This class represents an IN and NOT IN condition.
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/24/15
      class INCondition < Condition

        # Constructor to build either IN or NOT IN condition
        # @param left   attribute to compare
        # @param values values to use to build IN or NOT IN condition
        # @param not_in  indicates if this condition is a not in.
        def initialize(left, values, not_in = false)
          @left = left
          @values = values
          @not_in = not_in
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          condition = '"' + @left + '": {' + (@not_in ? '"$nin"' : '"$in"') + ': ['

          items = ''
          @values.each do |value|
            items = items + ((items.length == 0 ? '' : ',') + (value.is_a?(String) ? '"' : '') + value.to_s + (value.is_a?(String) ? '"' : ''))
          end

          condition + items + ']}'
        end
      end
      # End of INCondition class

      # This class represents a like condition <b>left like '%som%thing%'</b>
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/23/15
      class LikeCondition < Condition

        # This constructor will build a like condition using left and right part.
        # @param left  left part of this like condition.
        # @param right right part of this like condition.
        def initialize(left, right, not_like = false)
          @left = left
          @right = right
          @not_like = not_like
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          '"' + @left + '": { "$' + (@not_like ? 'n' : '') + 'like" : ' + '"' + @right + '"' + ' }'
        end
      end
      # End of LikeCondition class

      # This class represents a not equal condition <b>left != '%som%thing%'</b>
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/23/15
      class NotEqualCondition < Condition

        # Constructor tha builds this condition
        # @param left  attribute to compare
        # @param right right part of this condition
        def initialize(left, right)
          @left = left
          @right = right
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          '"$ne" : {"' + @left + '" : ' + (@right.is_a?(String) ? '"' : '') + (@right.to_s) + (@right.is_a?(String) ? '"' : '') + '}'
        end
      end
      # End of NotEqualCondition class

      # This class represents an is null or is not null condition.
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/23/15
      class NullCondition < Condition

        # Constructor tha builds this condition
        # @param left  attribute to compare
        # @param is_not_null flag that indicates what kind of comparison.
        def initialize(left, is_not_null = false)
          @left = left
          @is_not_null = is_not_null
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          '"' + @left + '": {' + (@is_not_null ? '"$notNull"' : '"$null"') + ': "1"}';
        end
      end
      # End of NullCondition class


      # This class represents an or condition.
      # Implements condition to return a JSON according left and right parts.
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/23/15
      class ORCondition < Condition

        # Constructor tha builds this condition
        # @param left  attribute to compare
        # @param right right part of this or condition
        def initialize(left, right)
          unless (left.is_a?(Condition)) || (right.is_a?(Condition))
            raise 'left and right should implement Condition'
          end

          @left = left
          @right = right
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          (parent.is_a?(ORCondition) ? '' : '"$or": {') + @left.to_record_string(self) + ',' +
              @right.to_record_string(self) + (parent.is_a?(ORCondition) ? '' : '}')
        end
      end
      # End of ORCondition class

      # This class represents a GroupBy clause.
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/23/15
      class GroupByClause < Condition

        # Constructor tha builds this condition
        # @param attributes attributes in group by clause
        def initialize(attributes)
          @attributes = attributes
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          group_by = '"groupBy": ['

          attrs = ''
          @attributes.each do |attr|
            attrs = attrs + (attrs.length == 0 ? '' : ',') + '"' + attr + '"';
          end

          group_by + attrs + ']'
        end
      end
      # End of GroupByClause class

      # This class represents an OrderBy clause
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/23/15
      class OrderByClause < Condition
        attr_accessor :asc, :attribute

        # Build an orderBy clause using asc flag
        # @param attribute attribute to use to order
        # @return an orderBy object
        def self.asc(attribute)
          order = OrderByClause.new
          order.asc = true
          order.attribute = attribute

          order
        end

        # Build an orderBy clause using desc flag
        # @param attribute attribute to use to order
        # @return an orderBy object
        def self.desc(attribute)
          order = OrderByClause.new
          order.asc = false
          order.attribute = attribute

          order
        end

        # This method will return a String of this condition
        # @param parent this is the parent of this condition
        # @return a json
        def to_record_string(parent)
          '"order": "' + attribute + (asc ? ' ASC' : ' DESC') + '"'
        end
      end
      # End of OrderByClause class


      # This is a builder to create conditions: AND, OR, LIKE, NOT LIKE, IN, NOT IN, EQUALS, GREATER THAN, GREATER EQUALS THAN
      # LESSER THAN, LESSER EQUALS THAN.
      # @author Eleazar Gomez
      # @version 1.0.0
      # @since 8/22/15
      class Conditions

        # It will build an and condition using two parts (Left and Right)
        # @param left  left part of and
        # @param right right part of and
        # @return A built condition
        def self.and(left, right)
          ANDCondition.new(left, right);
        end


        # It will build an or condition using two parts (Left and Right)
        # @param left  left part of or
        # @param right right part of or
        # @return A built condition.
        def self.or(left, right)
          ORCondition.new(left, right)
        end

        # It will an in condition using an array of values.
        # @param left attribute to compare
        # @param values character values to build IN condition
        # @return a built condition.
        def self.in(left, values)
          inner_in_condition(left, values, false)
        end

        # It will an in condition using an array of values.
        # @param left attribute to compare
        # @param values number values to build IN condition
        # @return a built condition.
        def self.not_in(left, values)
          inner_in_condition(left, values, true)
        end

        # It will build a like condition.
        # @param left attribute to comapare
        # @param like to use for like condition
        # @return a built condition.
        def self.like(left, like)
          LikeCondition.new(left, like, false)
        end

        # It will build a not like condition.
        # @param left attribute to comapare
        # @param like to use for like condition
        # @return a built condition.
        def self.not_like(left, like)
          LikeCondition.new(left, like, true)
        end

        # It will build an equals condition.
        # @param left attribute to compare
        # @param right right part of this condition
        # @return a built condition.
        def self.equals(left, right)
          inner_equals(left, right, Dynamicloud::API::Criteria::Condition::WITHOUT)
        end

        # It will build a not equals condition.
        # @param left attribute to compare
        # @param right right part of this condition
        # @return a built condition.
        def self.not_equals(left, right)
          inner_not_equals(left, right)
        end


        # It will build a greater equals condition.
        # @param left attribute to compare
        # @param right right part of this condition
        # @return a built condition.
        def self.greater_equals(left, right)
          inner_equals(left, right, '>')
        end


        # It will build a greater condition.
        # @param left attribute to compare
        # @param right right part of this condition
        # @return a built condition.
        def self.greater_than(left, right)
          GreaterLesser.new(left, right, '>')
        end


        # It will build a lesser condition.
        # @param left attribute to compare
        # @param right right part of this condition
        # @return a built condition.
        def self.lesser_than(left, right)
          GreaterLesser.new(left, right, '<')
        end

        # It will build a lesser equals condition.
        # @param left attribute to compare
        # @param right right part of this condition
        # @return a built condition.
        def self.lesser_equals(left, right)
          inner_equals(left, right, '<')
        end

        # This method will build a not equals condition.
        # @param left value to compare
        # @param right right part of this condition
        # @return a built condition
        private
        def self.inner_not_equals(left, right)
          NotEqualCondition.new(left, right)
        end

        # This method will build either a equals condition.
        # @param left value to compare
        # @param greater_lesser   indicates if greater or lesser condition must be added.
        # @return a built condition
        def self.inner_equals(left, right, greater_lesser)
          EqualCondition.new(left, right, greater_lesser)
        end

        # It will either an in or not in condition using an array of values and a boolean that indicates
        # what kind of IN will be built.
        # @param left attribute to compare
        # @param values values to build IN condition
        # @return a built condition.
        def self.inner_in_condition(left, values, not_in)
          INCondition.new(left, values, not_in)
        end
      end
    end
  end
end