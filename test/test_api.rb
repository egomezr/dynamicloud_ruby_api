require 'test/unit'
require_relative '../lib/dynamic_criteria'
require_relative '../lib/dynamic_api'
require_relative '../lib/dynamic_model'

class TestApi < Test::Unit::TestCase
  FILE_PATH = '/file.sql'
  TEST_CASE_FILE = '/test_file.sql'
  CSK = 'csk#...'
  ACI = 'aci#...'

  # Called before every test method runs. Can be used
  # to set up fixture information.
  MODEL_ID = -1
  AUX_MODEL_ID = -1
  BETWEEN_MODEL_ID = -1

  def setup
    @provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    @model_id = MODEL_ID
    @rid = -1
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown

  end

  #This a test case to check the equals operations.
  def test_equals_not_equals
    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.equals('email', 'ego@gmail.com')).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.equals('agefield', 23)).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.equals('email', 'nxnxnxnxn')).get_results
    assert_equal 0, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.not_equals('email', 'nxnxnxnxn')).get_results

    assert_equal 2, results.fast_returned_size
    assert_equal 2, results.total_records
    assert_equal 2, results.records.length
  end

  def test_greater_than_equals
    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.greater_equals('agefield', 23)).get_results
    assert_equal 2, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.greater_equals('agefield', 24)).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.greater_equals('agefield', 40)).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.greater_than('agefield', 40)).get_results
    assert_equal 0, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.greater_than('agefield', 23)).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.greater_than('agefield', 22)).get_results
    assert_equal 2, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.lesser_than('agefield', 22)).get_results
    assert_equal 0, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.lesser_than('agefield', 40)).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.lesser_than('agefield', 23)).get_results
    assert_equal 0, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.lesser_than('agefield', 24)).get_results
    assert_equal 1, results.records.length

    ######
  end

  def test_like
    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.like('email', 'ego%')).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com')).get_results
    assert_equal 2, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.like('email', '%e%')).get_results
    assert_equal 2, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.not_like('email', '%ego%')).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.not_like('email', '%.com%')).get_results
    assert_equal 0, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.not_like('email', '%eleazar%')).get_results
    assert_equal 2, results.records.length

    ######
  end

  def test_in
    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.in('email', ['ego@gmail.com'])).get_results
    assert_equal 1, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.in('email', ['eego@gmail.com'])).get_results
    assert_equal 0, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.not_in('email', ['eego@gmail.com'])).get_results
    assert_equal 2, results.records.length

    ######

    query = @provider.create_query @model_id
    results = query.add(Dynamicloud::API::Criteria::Conditions.not_in('email', ['ego@gmail.com'])).get_results
    assert_equal 1, results.records.length

    ######
  end

  def test_offset
    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    query.set_offset(1).set_count(1)

    results = query.get_results

    assert_equal 1, results.records.length

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    query.set_offset(0).set_count(2)

    results = query.get_results

    assert_equal 2, results.records.length

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    query.set_offset(2).set_count(2)

    results = query.get_results

    assert_equal 0, results.records.length

    ######
  end

  def test_projection
    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    result = query.get_results(['min(email)']).records[0]
    assert_equal 'ego@gmail.com', result['min(email)']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    result = query.get_results(['max(email)']).records[0]
    assert_equal 'elea@yahoo.com', result['max(email)']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    result = query.get_results(['avg(agefield)']).records[0]
    assert_equal 31.5, result['avg(agefield)']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    result = query.get_results(['sum(agefield)']).records[0]
    assert_equal 63.0, result['sum(agefield)']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    results = query.get_results(['distinct(email)'])
    assert_equal 2, results.records.length

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%'))
    result = query.get_results(['count(*)']).records[0]
    assert_equal 2, result['count(*)']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%')).set_count(1).set_offset(1)
    result = query.get_results(['email']).records[0]
    assert_equal 'elea@yahoo.com', result['email']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%')).set_count(1).set_offset(1)
    result = query.get_results(['agefield']).records[0]
    assert_equal '40', result['agefield']

    ######

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%')).set_count(1).set_offset(1)
    result = query.get_results(['agefield']).records[0]
    assert_equal nil, result['agefields']

    ######
  end

  def test_update_selection
    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.equals('email', 'ego@gmail.com'))
    @provider.update query, {'birthdat' => '2015-05-22', 'email' => 'ego@gmail.com'}

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.equals('email', 'ego@gmail.com'))
    result = query.get_results.records[0]
    assert_equal '2015-05-22', result['birthdat']
  end

  def test_load_record
    record = (@provider.load_record 2, @model_id)
    assert_equal 'ego@gmail.com', record['email']
  end

  def test_big_text_field
    record = (@provider.load_record 2, @model_id)
    assert_equal nil, record['photo']
  end

  def test_update_record
    record = (@provider.load_record 2, @model_id)
    record['birthdat'] = '2015-05-23'

    @provider.update_record @model_id, record

    record = (@provider.load_record 2, @model_id)

    assert_equal '2015-05-23', record['birthdat']
  end

  def test_create_delete_record
    record = (@provider.load_record 2, @model_id)
    record.delete 'rid'
    record['email'] = 'eeee@gmail.com'

    @provider.save_record @model_id, record

    @rid = record['rid'].to_i

    @provider.delete_record @model_id, @rid

    record = nil
    begin
      record = (@provider.load_record @rid, @model_id)
    rescue StandardError => se
      puts se
    end

    assert_equal nil, record
  end

  def test_delete_selection
    record = (@provider.load_record 2, @model_id)
    record.delete 'rid'
    record['email'] = 'eeee@gmail.com'

    @provider.save_record @model_id, record

    @rid = record['rid'].to_i

    #########################

    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.equals('email', 'eeee@gmail.com'))
    @provider.delete query, @model_id

    #########################

    record = nil
    begin
      record = (@provider.load_record @rid, @model_id)
    rescue StandardError => se
      puts se
    end

    assert_equal nil, record
  end

  def test_load_model
    model = @provider.load_model @model_id

    assert_equal 'Model#41', model.name
    assert_equal @model_id, model.id
  end

  def test_load_models
    models = @provider.load_models
    assert_true models.length >= 2
    assert_respond_to models, :each
  end

  def test_load_fields
    fields = @provider.load_fields @model_id
    assert_not_nil fields
    assert_respond_to fields, :each
    assert fields.length > 0
  end

  def test_next_method
    query = (@provider.create_query @model_id).add(Dynamicloud::API::Criteria::Conditions.like('email', '%.com%')).set_count(1).set_offset(0)
    result = query.get_results(['agefield']).records[0]

    assert_equal '23', result['agefield']

    result = query.next.records[0]

    assert_equal '40', result['agefield']

    results = query.next

    assert_equal 0, results.fast_returned_size
  end

  def test_item_values
    record = (@provider.load_record 2, @model_id)
    record['country'] = 'bra'

    @provider.update_record @model_id, record

    record = (@provider.load_record 2, @model_id)

    assert_equal 'bra', record['country']
  end

  def test_multi_item_values
    record = (@provider.load_record 2, @model_id)
    record['password'] = '01,02'

    @provider.update_record @model_id, record

    record = (@provider.load_record 2, @model_id)

    assert_equal %w(01 02), record['password']
  end

  def test_share_down_upload_file
    @provider.upload_file @model_id, 2, 'photo', File.new(FILE_PATH, 'r'), 'application/txt', 'ThisIsAnExample.sql'

    link = @provider.share_file @model_id, 2, 'photo'
    assert !link.nil?

    if File.exists? TEST_CASE_FILE
      File.delete TEST_CASE_FILE
    end

    @provider.download_file @model_id, 2, 'photo', File.new(TEST_CASE_FILE, 'w')

    assert File.exists?(TEST_CASE_FILE)
  end

  def test_alias_presence_join
    begin
      provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                        :aci => ACI})

      query = provider.create_query(MODEL_ID)

      query.join(Dynamicloud::API::Criteria::Conditions.left_join(AUX_MODEL_ID, 'aux', 'user.id = aux.modelid'))

      query.get_results(['user.country as country', 'aux.birthdat as birthdate'])

      fail('Server didn\'t validate alias presence.')
    rescue
      #ignore
    end
  end

  def test_left_join
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                      :aci => ACI})

    query = provider.create_query(MODEL_ID)

    # This is the alias to 980190974, this alias is necessary to use JoinClause
    query.set_alias 'user'

    query.join(Dynamicloud::API::Criteria::Conditions.left_join(AUX_MODEL_ID, 'aux', 'user.id = aux.modelid'))
    query.order_by('user.country')

    results = query.get_results(['user.country as country', 'aux.birthdat as birthdate'])

    if results.fast_returned_size > 0
      record = results.records[0]

      assert_equal 'bra', record['country']
      assert_equal '2015-11-11', record['birthdate']

      return
    end

    fail('Without results.  That\'s wrong!')
  end

  def test_left_outer_join
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                      :aci => ACI})

    query = provider.create_query(MODEL_ID)

    # This is the alias to 980190974, this alias is necessary to use JoinClause
    query.set_alias 'user'

    query.join(Dynamicloud::API::Criteria::Conditions.left_outer_join(AUX_MODEL_ID, 'aux', 'user.id = aux.modelid'))
    query.order_by('user.country')

    results = query.get_results(['user.country as country', 'aux.birthdat as birthdate'])

    if results.fast_returned_size > 0
      record = results.records[0]

      assert_equal 'bra', record['country']
      assert_equal '2015-11-11', record['birthdate']

      return
    end

    fail('Without results.  That\'s wrong!')
  end

  def test_right_outer_join
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                      :aci => ACI})

    query = provider.create_query(MODEL_ID)

    # This is the alias to 980190974, this alias is necessary to use JoinClause
    query.set_alias 'user'

    query.join(Dynamicloud::API::Criteria::Conditions.right_outer_join(AUX_MODEL_ID, 'aux', 'user.id = aux.modelid'))
    query.order_by('user.country')

    results = query.get_results(['user.country as country', 'aux.birthdat as birthdate'])

    if results.fast_returned_size > 0
      record = results.records[0]

      assert_equal 'bra', record['country']
      assert_equal '2015-11-11', record['birthdate']

      return
    end

    fail('Without results.  That\'s wrong!')
  end

  def test_right_join
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                      :aci => ACI})

    query = provider.create_query(MODEL_ID)

    # This is the alias to 980190974, this alias is necessary to use JoinClause
    query.set_alias 'user'

    query.join(Dynamicloud::API::Criteria::Conditions.right_join(AUX_MODEL_ID, 'aux', 'user.id = aux.modelid'))
    query.order_by('user.country')

    results = query.get_results(['user.country as country', 'aux.birthdat as birthdate'])

    if results.fast_returned_size > 0
      record = results.records[0]

      assert_equal 'bra', record['country']
      assert_equal '2015-11-11', record['birthdate']

      return
    end

    fail('Without results.  That\'s wrong!')
  end

  def test_join_and_selection
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                      :aci => ACI})

    query = provider.create_query(MODEL_ID)

    # This is the alias to 980190974, this alias is necessary to use JoinClause
    query.set_alias 'user'

    query.join(Dynamicloud::API::Criteria::Conditions.left_join(AUX_MODEL_ID, 'aux', 'user.id = aux.modelid'))
    query.add(Dynamicloud::API::Criteria::Conditions.equals('aux.birthdat', '2015-09-15'))
    query.order_by('user.country')

    results = query.get_results(['user.country as country', 'aux.birthdat as birthdate'])

    if results.fast_returned_size > 0
      record = results.records[0]

      assert_equal 'us', record['country']
      assert_equal '2015-09-15', record['birthdate']

      return
    end

    fail('Without results.  That\'s wrong!')
  end

  def test_between_condition
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK,
                                                      :aci => ACI})

    query = provider.create_query(MODEL_ID)
    condition = Dynamicloud::API::Criteria::Conditions.between('agefield', 20, 40)
    query.add condition

    results = query.get_results
    assert_equal(2, results.fast_returned_size)

    query = provider.create_query(BETWEEN_MODEL_ID)
    condition = Dynamicloud::API::Criteria::Conditions.between('datefie', '2015-11-28 00:00:00', '2015-11-28 23:59:59')
    query.add condition

    results = query.get_results
    assert_true(results.fast_returned_size > 1)

    query = provider.create_query(BETWEEN_MODEL_ID)
    condition = Dynamicloud::API::Criteria::Conditions.between('datefie', '2015-11-28 01:00:00', '2015-11-28 23:59:59')
    query.add condition

    results = query.get_results
    assert_true(results.fast_returned_size == 0)
  end

  def test_exists_condition
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query(MODEL_ID)

    # This is the alias to model_id, this alias is necessary to use JoinClause
    query.set_alias 'user'

    exists_condition = Dynamicloud::API::Criteria::Conditions.exists(AUX_MODEL_ID, 'aux')

    # The dollar symbols are to avoid to use right part as a String
    exists_condition.add(Dynamicloud::API::Criteria::Conditions.not_equals('user.id', '$aux.modelid$'))

    query.add exists_condition

    results = query.get_results

    assert_true results.fast_returned_size == 2
    assert_false results.records.length == 0
  end

  def test_exists_join
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query(MODEL_ID)

    # This is the alias to model_id, this alias is necessary to use JoinClause
    query.set_alias 'user'

    exists_condition = Dynamicloud::API::Criteria::Conditions.exists(AUX_MODEL_ID, 'aux')
    exists_condition.join(Dynamicloud::API::Criteria::Conditions.inner_join(AUX_MODEL_ID, 'auxx', 'aux.id = auxx.modelid'))

    # The dollar symbols are to avoid to use right part as a String
    exists_condition.add(Dynamicloud::API::Criteria::Conditions.not_equals('user.id', '$aux.modelid$'))

    query.add exists_condition

    results = query.get_results

    assert_true results.fast_returned_size == 2
    assert_false results.records.length == 0
  end

  def test_not_exists_join
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query(MODEL_ID)

    # This is the alias to model_id, this alias is necessary to use JoinClause
    query.set_alias 'user'

    exists_condition = Dynamicloud::API::Criteria::Conditions.not_exists(AUX_MODEL_ID, 'aux')
    exists_condition.join(Dynamicloud::API::Criteria::Conditions.inner_join(AUX_MODEL_ID, 'auxx', 'aux.id = auxx.modelid'))

    # The dollar symbols are to avoid to use right part as a String
    exists_condition.add(Dynamicloud::API::Criteria::Conditions.not_equals('user.id', '$aux.modelid$'))

    query.add exists_condition

    results = query.get_results

    assert_true results.fast_returned_size == 0
    assert_true results.records.length == 0
  end
end