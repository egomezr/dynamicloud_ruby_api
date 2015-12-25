require_relative 'exceptions'
require_relative 'dynamic_service'
require_relative 'dynamic_model'
require_relative '../lib/configuration'
require 'json'
require 'rubygems'
require 'open-uri'

module Dynamicloud
  class API
    # This class contains data returned from Dynamicloud servers.
    # @author Eleazar Gomez
    # @version 1.0.0
    # @since 8/26/15
    class RecordResults
      attr_accessor(:records, :total_records, :fast_returned_size)

      def initialize
        @records = []
        @total_records = 0
        @fast_returned_size = 0
      end
    end

    class RecordQuery

      DEFAULT_COUNT = 15

      def initialize(mid)
        @mid = mid
        @credentials = nil
        @order_by = nil
        @group_by = nil
        @offset = -1
        @count = -1
        @current_callback = nil
        @list_was_called = false
        @conditions = []
        @joins = []
        @alias = nil
        @current_projection = nil
      end

      # Attaches a alias to this query, the model in this query will use this alias in Join Clauses or whatever situation where alias is needed.
      #
      # @param aliass alias to attach
      # @return this instance of Query
      def set_alias(aliass)
        @alias = aliass
      end

      # Add a join to the list of joins
      #
      # @param join_clause join clause
      # @return this instance of Query
      def join(join_clause)
        @joins.push join_clause
        self
      end

      # Apply a desc ordering to the current order by object
      # An IllegalStateException will be thrown if orderBy object is nil
      #
      # @return this instance of Query
      def desc
        if @order_by.nil?
          raise Exceptions::IllegalStateException, 'You must call order_by method before call this method'
        end

        @order_by.asc = false

        self
      end

      # Apply a asc ordering to the current order by object
      # An IllegalStateException will be thrown if orderBy object is nil
      #
      # @return this instance of Query
      def asc
        if @order_by.nil?
          raise Exceptions::IllegalStateException, 'You must call order_by method before call this method'
        end

        @order_by.asc = true

        self
      end

      # This method will add a new condition to an AND list of conditions.
      #
      # @param condition new condition to a list of conditions to use
      # @return this instance of Query
      def add(condition)
        @conditions.push(condition)
        self
      end

      # This method sets the projection to use in this query.  The def execution will return those projection.
      # If projection == nil then, this def will returns all model's projection.
      #
      # @param projection projection in this query
      # @return this instance of Query
      #def add_projection(projection)
      # @projection = projection
      #self
      #end

      # Sets an offset to this query to indicates the page of a big data result.
      #
      # @param offset new offset
      # @return this instance of Query
      def set_offset(offset)
        @offset = offset
        self
      end

      # Sets how many items per page (offset) this def will fetch
      #
      # @param count how many items
      # @return this instance of Query
      def set_count(count)
        @count = count
        self
      end

      # Gets the current count
      # If count == 0 then will return default count (DEFAULT_COUNT)
      #
      # @return the current count
      def get_count
        @count <= 0 ? DEFAULT_COUNT : @count;
      end

      # This method will execute a query and returns a list of records
      # @param projection projection to use in this operation
      def get_results(projection = nil)
        selection = Dynamicloud::API::DynamicloudHelper.build_string(get_conditions, get_group_by, get_order_by,
                                                                     (Dynamicloud::API::DynamicloudHelper.build_projection(projection)),
                                                                     @alias, @joins)
        @current_projection = projection

        url = Configuration::PROPERTIES.get_property :url
        if projection
          url_get_records = Configuration::PROPERTIES.get_property :url_get_specific_fields
        else
          url_get_records = Configuration::PROPERTIES.get_property :url_get_records
        end

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credentials[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credentials[:aci])
        url_get_records = url_get_records.gsub '{mid}', @mid.to_s
        url_get_records = url_get_records.gsub '{count}', get_count.to_s
        url_get_records = url_get_records.gsub '{offset}', get_current_offset.to_s

        params = {
            :criteria => selection
        }

        response = DynamicService::ServiceCaller.call_service url + url_get_records, params, 'post'

        Dynamicloud::API::DynamicloudHelper.build_record_results response

      end

      # This method adds an order by condition.  The condition will have an asc ordering by default.
      #
      # @param attribute attribute by this query will be ordered.
      # @return this instance of Query
      def order_by(attribute)
        @order_by = Dynamicloud::API::Criteria::OrderByClause.asc(attribute)
        self
      end

      # This method create a groupBy condition using attribute
      #
      # @param attribute attribute by this query will group.
      # @return this instance of Query
      def group_by(attribute)
        @group_by = Dynamicloud::API::Criteria::GroupByClause.new(attribute)
        self
      end

      # get the current conditions
      #
      # @return the conditions
      def get_conditions
        @conditions
      end

      # Gets the current offset so far.  This attribute will increase according calls of method next(RecordCallback<T> callback)
      #
      # @return int of current offset
      def get_current_offset
        @offset < 0 ? 0 : @offset
      end

      # Will execute a list operation with an offset += count and will use the same callback object in list method.
      # This method will return a RecordResults object
      def next
        @offset = get_current_offset + get_count
        get_results @current_projection
      end

      # Returns the current model id associated to this query
      # @return model id
      def get_model_id
        @mid
      end

      # Sets the credentials to use
      #
      # @param credentials credentials to execute operations.
      def set_credentials(credentials)
        @credentials = credentials
      end

      # get the current orderBy condition
      # @return the order by condition
      def get_order_by
        @order_by
      end

      # get the current groupBy condition
      #
      # @return the group by condition
      def get_group_by
        @group_by
      end

      # This method create a groupBy condition using projection
      #
      # @param attributes projection by this query will group.
      def set_group_by(attributes)
        @group_by = GroupByClause.new(attributes)
      end
    end

    # This class represents a record in Dynamicloud
    # @author Eleazar Gomez
    # @version 1.0.0
    # @since 8/24/15
    class RecordImpl
      def initialize
        @map = {}
      end

      # gets the value paired with attribute
      # @param attribute attribute to use
      # @return the value paired with attribute
      def get_value(attribute)
        obj = @map[attribute]
        if obj
          if obj.is_a?(String)
            return obj.to_s
          end
        end

        raise IllegalStateException, "The attribute #{attribute} doesn't have a paired string."
      end

      # get the values paired with attribute
      # @param attribute attribute to use
      # @return the values paired with attribute
      def get_values(attribute)
        obj = @map[attribute]
        if obj
          if obj.respond_to?(:each)
            return obj
          end
        end

        raise IllegalStateException, "Tha attribute #{attribute} doesn't have a paired string array."
      end

      # Adds a new value paired with attribute
      # @param attribute attribute to be paired
      # @param value     value
      def add_value(attribute, value)
        @map[attribute] = value
      end
    end

    # This class represents an error from Dynamicloud servers
    # @author Eleazar Gomez
    # @version 1.0.0
    # @since 8/25/15
    class RecordError
      attr_accessor(:message, :code)

      def initialize
        @message = ''
        @code = ''
      end
    end

    # This class has two attributes CSK and ACI keys.  This information is provided at moment the registration in Dynamicloud.
    # @author Eleazar Gomez
    # @version 1.0.0
    # @since 8/25/15
    class DynamicProvider
      def initialize(credential)
        @credential = credential
      end

      # This method will load a record using rid and will instantiate a hash with attributes bound to Model's fields.
      # @param rid        record id
      # @param mid        model id
      # @return a hash with record information
      def load_record(rid, mid)
        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_get_record_info

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s
        url_get_records = url_get_records.gsub '{rid}', rid.to_s

        response = DynamicService::ServiceCaller.call_service url + url_get_records, {}, 'get'

        json = JSON.parse(response)
        record = json['record']

        unless record
          raise 'Record key doesn\'t present in response from Dynamicloud server.'
        end

        Dynamicloud::API::DynamicloudHelper.normalize_record record
      end

      # This method will call an update operation in Dynamicloud servers
      # using model and data object
      # @param mid    model id
      # @param data this hash should contain a key rid (RecordId) otherwise an error will be thrown
      def update_record(mid, data)
        rid = data['rid']

        unless rid
          raise "rid attribute isn't present in hash data."
        end

        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_update_record

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s
        url_get_records = url_get_records.gsub '{rid}', rid.to_s

        params = {
            :fields => Dynamicloud::API::DynamicloudHelper.build_fields_json(data)
        }

        response = DynamicService::ServiceCaller.call_service url + url_get_records, params, 'post'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end
      end

      # This method will call a save operation in DynamiCloud servers
      # using model and BoundInstance object
      # @param mid    model id
      # @param data all data needed to save a record in model (mid)
      def save_record(mid, data)
        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_save_record

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s

        params = {
            :fields => Dynamicloud::API::DynamicloudHelper.build_fields_json(data)
        }

        response = DynamicService::ServiceCaller.call_service url + url_get_records, params, 'post'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end

        data['rid'] = json['rid']

        data
      end

      # This method will call a delete operation in DynamiCloud servers
      # using model id and Record id
      # @param mid model id
      # @param rid   record id
      def delete_record(mid, rid)
        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_delete_record

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s
        url_get_records = url_get_records.gsub '{rid}', rid.to_s

        response = DynamicService::ServiceCaller.call_service url + url_get_records, {}, 'delete'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end
      end

      # Will create a RecordQuery and sets to this provider
      # @param mid model id to use to execute operations
      # @return this Dynamicloud::API::RecordQuery instance
      def create_query(mid)
        query = Dynamicloud::API::RecordQuery.new mid
        query.set_credentials @credential

        query
      end

      # Gets model record information from DynamiCloud servers.
      # @param mid model id in DynamiClod servers
      # @return RecordModel object
      def load_model(mid)
        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_get_model_info

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s

        response = DynamicService::ServiceCaller.call_service url + url_get_records, {}, 'get'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end

        model = Dynamicloud::API::Model::RecordModel.new mid
        model.name = json['name']
        model.description = json['description']

        model
      end

      # Loads all models related to CSK and ACI keys in Dynamicloud servers
      # @return list of models
      def load_models
        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_get_models

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])

        response = DynamicService::ServiceCaller.call_service url + url_get_records, {}, 'get'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end

        models = []
        array = json['models']
        array.each do |item|
          model = Dynamicloud::API::Model::RecordModel.new item['id'].to_i
          model.name = item['name']
          model.description = item['description']

          models.push model
        end

        models
      end

      # Loads all model's fields according ModelID
      # @param mid model id
      # @return list of model's fields.
      def load_fields(mid)
        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_get_fields

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s

        response = DynamicService::ServiceCaller.call_service url + url_get_records, {}, 'get'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end

        fields = []
        fs = json['fields']
        fs.each do |key, jf|
          field = Dynamicloud::API::Model::RecordField.new
          field.id = jf['id'].to_i
          field.identifier = jf['identifier']
          field.label = jf['label']
          field.comment = jf['comment']
          field.uniqueness = jf['uniqueness']
          field.required = jf['required']
          field.type = Dynamicloud::API::Model::RecordFieldType.get_field_type jf['field_type'].to_i
          field.items = Dynamicloud::API::DynamicloudHelper.build_items jf['items']
          field.mid = mid.to_i

          fields.push field
        end

        fields
      end

      # Executes an update using query as a selection and data with values
      # Dynamicloud will normalize the key pair values.  That is, will be used field identifiers only.
      # @param data data that will be sent to Dynamicloud servers
      # @param query selection
      def update(query, data = {})
        selection = Dynamicloud::API::DynamicloudHelper.build_string(query.get_conditions, nil, nil, nil)
        fields = '{"updates": ' + Dynamicloud::API::DynamicloudHelper.build_fields_json(data) + '}'

        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_update_selection

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', query.get_model_id.to_s

        params = {
            :fields => fields,
            :selection => selection
        }

        response = DynamicService::ServiceCaller.call_service url + url_get_records, params, 'post'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end
      end

      # Executes a delete using query as a selection
      # @param query selection
      # @param mid model id
      def delete(query, mid)
        selection = Dynamicloud::API::DynamicloudHelper.build_string(query.get_conditions, nil, nil, nil)

        url = Configuration::PROPERTIES.get_property :url
        url_get_records = Configuration::PROPERTIES.get_property :url_delete_selection

        url_get_records = url_get_records.gsub '{csk}', URI::encode(@credential[:csk])
        url_get_records = url_get_records.gsub '{aci}', URI::encode(@credential[:aci])
        url_get_records = url_get_records.gsub '{mid}', mid.to_s

        params = {
            :selection => selection
        }

        response = DynamicService::ServiceCaller.call_service url + url_get_records, params, 'post'

        json = JSON.parse(response)
        unless json['status'] == 200
          raise json['message']
        end
      end
    end

    # This is a class with utility methods
    # @author Eleazar Gomez
    # @version 1.0.0
    # @since 8/26/15
    class DynamicloudHelper
      #This method will normalize the response from Dynamicloud servers
      def self.normalize_record(record)
        normalized = {}
        record.each do |key, value|
          if value.is_a?(Hash)
            #This hash has only one key
            value.each do |ik, iv|
              if iv.respond_to?(:each)
                array = []
                iv.each do |item|
                  array.push item.to_s
                end

                normalized[key] = array
              elsif iv.is_a?(String)
                normalized[key] = iv.to_s
              end

              #This hash has only one key
              break
            end
          else
            normalized[key] = value
          end
        end

        normalized
      end

      # Builds a compatible string to update a record.
      # This method will get field name and its value form data hash.
      # @param instance Object where data is extracted
      # @return compatible string
      def self.build_fields_json(data)
        result = data.clone
        data.each do |key, value|
          if value.respond_to?(:each)
            array = ''
            value.each do |item|
              if item
                array = array + (array == '' ? '' : ',') + item.to_s
              end
            end
            result[key] = array
          end
        end

        result.to_json
      end

      # Builds an array of RecordFieldItems according JSONArray
      # @param array JSONArray with pair value, text.
      def self.build_items(array)
        items = []
        if array.length > 0
          array.each do |item|
            ri = Dynamicloud::API::Model::RecordFieldItem.new
            ri.text = item['text']
            ri.value = item['value']

            items.push ri
          end
        end

        items
      end

      # Builds a compatible String to use in service executions
      # @return compatible String
      def self.build_string(conditions, group_by, order_by, projection, aliass = nil, joins = [])
        built = '{' + (aliass == nil ? '' : '"alias": "' + aliass + '", ') + build_join_tag(joins) +
            ((projection.nil? || projection.eql?('') || projection.strip!.eql?('')) ? '' : (', ' + projection)) + ', "where": {'

        if conditions.length > 0
          global = conditions[0]
          if conditions.length > 1
            conditions = conditions[1..conditions.length]
            conditions.each do |condition|
              global = Dynamicloud::API::Criteria::ANDCondition.new global, condition
            end
          end

          built = built + global.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)
        end

        built = built + '}'

        if group_by
          built = built + ',' + group_by.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)
        end

        if order_by
          built = built + ',' + order_by.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)
        end

        built + '}'
      end

      # Build a compatible string using projection
      # @return string using projection
      def self.build_projection(projection)
        unless (projection) && (projection.length > 0)
          return ''
        end

        columns = '"columns": ['
        cols = ''
        projection.each do |field|
          cols = cols + (cols == '' ? '' : ',') + '"' + field + '"'
        end

        columns + cols + ']'
      end

      # This method builds the tag joins as follows:
      # i.e: "joins": [ { "type": "full", "alias": "user", "target": "3456789", "on": { "user.id" : "languages.id" } } ]
      #
      # @param joins list of join clauses
      # @return the representation of a join tag.
      def self.build_join_tag(joins)
        tag = '"joins": ['

        unless joins.nil?
          first_time = true
          joins.each do |clause|
            tag += (first_time ? '' : ', ') + clause.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

            first_time = false
          end
        end

        return tag + ']'
      end

      # This utility will build a RecordResults object
      # @param response   ServiceResponse from Dynamicloud servers
      def self.build_record_results(response)
        results = Dynamicloud::API::RecordResults.new

        json = JSON.parse(response)

        data = json['records']

        results.total_records = data['total']
        results.fast_returned_size = data['size']
        results.records = get_record_list(data)

        results
      end

      # This method will extract data and Bind each field with attributes in mapper:getInstance method instance
      # @param data       json with all data from Dynamicloud servers
      # @return list of records
      def self.get_record_list(data)
        record_list = []

        records = data['records']

        records.each do |jr|
          record_list.push(build_record(jr))
        end

        record_list
      end

      # Builds the record hash with data from jr JSON object
      def self.build_record(jr)
        record = {}

        jr.each do |key, value|
          if value.is_a?(Hash)
            value.each do |k, v|
              if v.respond_to?(:each)
                values = []
                v.each do |item|
                  values.push(item.to_s)
                end

                record[key] = values
              else
                record[key] = value
              end

              break
            end
          else
            record[key] = value
          end
        end

        record
      end
    end
  end
end