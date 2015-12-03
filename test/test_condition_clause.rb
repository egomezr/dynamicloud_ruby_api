require 'test/unit'
require_relative '../lib/dynamic_criteria'
require_relative '../lib/dynamic_api'
require_relative '../lib/dynamic_model'

#This a suite of test cases to ensure condition building
class TestConditionClause < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown

  end

  # Test an equal condition and its variants
  def test_equal_condition
    condition = Dynamicloud::API::Criteria::EqualCondition.new 'age', 32, '<'

    assert_equal '"age" : { "$lte": 32 }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::GreaterLesser.new 'age', 32, '<'

    assert_equal '"age": { "$lt": 32 }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::GreaterLesser.new 'age', 32, '>'

    assert_equal '"age": { "$gt": 32 }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::EqualCondition.new 'age', '32', '<'

    assert_equal '"age" : { "$lte": "32" }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::EqualCondition.new 'age', '32', '>'

    assert_equal '"age" : { "$gte": "32" }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::EqualCondition.new 'age', 32, '>'

    assert_equal '"age" : { "$gte": 32 }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::EqualCondition.new 'age', 32

    assert_equal '"age" : 32', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::EqualCondition.new 'age', '32'

    assert_equal '"age" : "32"', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  # Test an in condition and its variants
  def test_in_condition
    condition = Dynamicloud::API::Criteria::INCondition.new 'age', [1, 2, 3]

    assert_equal '"age": {"$in": [1,2,3]}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::INCondition.new 'age', %w(1 2 3)

    assert_equal '"age": {"$in": ["1","2","3"]}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::INCondition.new 'age', [1, 2, 3], true

    assert_equal '"age": {"$nin": [1,2,3]}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::INCondition.new 'age', %w(1 2 3), true

    assert_equal '"age": {"$nin": ["1","2","3"]}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  # Test a like condition and its variants
  def test_like_condition
    condition = Dynamicloud::API::Criteria::LikeCondition.new 'name', '%eleazar%'

    assert_equal '"name": { "$like" : "%eleazar%" }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::LikeCondition.new 'name', '%eleazar%', true

    assert_equal '"name": { "$nlike" : "%eleazar%" }', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  # Test a not equal condition and its variants
  def test_not_equal_condition
    condition = Dynamicloud::API::Criteria::NotEqualCondition.new 'name', 'eleazar'

    assert_equal '"$ne" : {"name" : "eleazar"}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::NotEqualCondition.new 'age', 4

    assert_equal '"$ne" : {"age" : 4}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  # Test a null condition and its variants
  def test_null_condition
    condition = Dynamicloud::API::Criteria::NullCondition.new 'name'

    assert_equal '"name": {"$null": "1"}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::NullCondition.new 'name', true

    assert_equal '"name": {"$notNull": "1"}', (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  # Test an or condition and its variants
  def test_or_condition
    condition = Dynamicloud::API::Criteria::ORCondition.new (Dynamicloud::API::Criteria::NullCondition.new 'name'),
                                                            (Dynamicloud::API::Criteria::NullCondition.new 'name', true)

    assert_equal '"$or": {"name": {"$null": "1"},"name": {"$notNull": "1"}}',
                 (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::ORCondition.new (Dynamicloud::API::Criteria::LikeCondition.new 'name', '%eleazar%'),
                                                            (Dynamicloud::API::Criteria::NullCondition.new 'name', true)

    assert_equal '"$or": {"name": { "$like" : "%eleazar%" },"name": {"$notNull": "1"}}',
                 (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    begin
      Dynamicloud::API::Criteria::ORCondition.new '', ''
    rescue StandardError => se
      assert_equal 'left and right should implement Condition', se.message
      return
    end

    fail('OR condition should validate params')
  end

  # Test an and condition and its variants
  def test_and_condition
    condition = Dynamicloud::API::Criteria::ANDCondition.new (Dynamicloud::API::Criteria::NullCondition.new 'name'),
                                                             (Dynamicloud::API::Criteria::NullCondition.new 'name', true)

    assert_equal '"name": {"$null": "1"},"name": {"$notNull": "1"}',
                 (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    condition = Dynamicloud::API::Criteria::ANDCondition.new (Dynamicloud::API::Criteria::LikeCondition.new 'name', '%eleazar%'),
                                                             (Dynamicloud::API::Criteria::NullCondition.new 'name', true)

    assert_equal '"name": { "$like" : "%eleazar%" },"name": {"$notNull": "1"}',
                 (condition.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    begin
      Dynamicloud::API::Criteria::ANDCondition.new '', ''
    rescue StandardError => se
      assert_equal 'left and right should implement Condition', se.message
      return
    end

    fail('AND condition should validate params')
  end

  # Test a group by clause
  def test_group_by_clause
    clause = Dynamicloud::API::Criteria::GroupByClause.new %w(name age)

    assert_equal '"groupBy": ["name","age"]',
                 (clause.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  # Test a order by clause
  def test_order_by_clause
    clause = Dynamicloud::API::Criteria::OrderByClause.asc('name')

    assert_equal '"order": "name ASC"',
                 (clause.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'

    clause = Dynamicloud::API::Criteria::OrderByClause.desc('name')

    assert_equal '"order": "name DESC"',
                 (clause.to_record_string Dynamicloud::API::Criteria::Condition::ROOT), 'Wrong condition'
  end

  def test_join_clause
    mid = 234
    join = Dynamicloud::API::Criteria::Conditions.left_join(mid, 'user', 'user.id = id')
    assert_equal '{ "type": "left", "alias": "user", "target": "234", "on": "user.id = id" }', join.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

    join = Dynamicloud::API::Criteria::Conditions.left_join(mid, 'user', 'user.id = language.userid')
    assert_equal '{ "type": "left", "alias": "user", "target": "234", "on": "user.id = language.userid" }', join.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

    join = Dynamicloud::API::Criteria::Conditions.left_outer_join(mid, 'user', 'user.id = language.userid')
    assert_equal '{ "type": "left outer", "alias": "user", "target": "234", "on": "user.id = language.userid" }', join.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

    join = Dynamicloud::API::Criteria::Conditions.right_join(mid, 'user', 'user.id = language.userid')
    assert_equal '{ "type": "right", "alias": "user", "target": "234", "on": "user.id = language.userid" }', join.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

    join = Dynamicloud::API::Criteria::Conditions.right_outer_join(mid, 'user', 'user.id = language.userid')
    assert_equal '{ "type": "right outer", "alias": "user", "target": "234", "on": "user.id = language.userid" }', join.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

    join = Dynamicloud::API::Criteria::Conditions.inner_join(mid, 'user', 'user.id = language.userid')
    assert_equal '{ "type": "inner", "alias": "user", "target": "234", "on": "user.id = language.userid" }', join.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)
  end

  def test_between_condition
    condition = Dynamicloud::API::Criteria::Conditions.between('age', 20, 40)

    assert_equal '"age": { "$between": [20,40]}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)

    condition = Dynamicloud::API::Criteria::Conditions.between('date', '2015-11-01 00:00:00', '2015-11-01 23:59:59')

    assert_equal '"date": { "$between": ["2015-11-01 00:00:00","2015-11-01 23:59:59"]}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT)
  end

  def test_exists_condition
    condition = Dynamicloud::API::Criteria::Conditions.exists(1455545, 'inner')
    condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner.user_id', 'vip.user_id'))

    assert_equal('"$exists": { "joins": [], "model": 1455545, "alias": "inner", "where": {"inner.user_id" : "vip.user_id"}}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT))

    condition = Dynamicloud::API::Criteria::Conditions.exists(1455545)
    condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner.user_id', 'vip.user_id'))

    assert_equal('"$exists": { "joins": [], "model": 1455545, "where": {"inner.user_id" : "vip.user_id"}}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT))

    condition = Dynamicloud::API::Criteria::Conditions.exists
    condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner.user_id', '$vip.user_id$'))

    inner_condition = Dynamicloud::API::Criteria::Conditions.exists(54545, 'inner2')
    inner_condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner2.user_id', '$vip2.user_id$'))

    condition.add(inner_condition)

    assert_equal('"$exists": { "joins": [], "where": {"inner.user_id" : "$vip.user_id$","$exists": { "joins": [], "model": 54545, "alias": "inner2", "where": {"inner2.user_id" : "$vip2.user_id$"}}}}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT))

    ########

    condition = Dynamicloud::API::Criteria::Conditions.not_exists(1455545, 'inner')
    condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner.user_id', 'vip.user_id'))

    assert_equal('"$nexists": { "joins": [], "model": 1455545, "alias": "inner", "where": {"inner.user_id" : "vip.user_id"}}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT))

    condition = Dynamicloud::API::Criteria::Conditions.not_exists(1455545)
    condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner.user_id', 'vip.user_id'))

    assert_equal('"$nexists": { "joins": [], "model": 1455545, "where": {"inner.user_id" : "vip.user_id"}}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT))

    condition = Dynamicloud::API::Criteria::Conditions.not_exists
    condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner.user_id', '$vip.user_id$'))

    inner_condition = Dynamicloud::API::Criteria::Conditions.exists(54545, 'inner2')
    inner_condition.add(Dynamicloud::API::Criteria::Conditions.equals('inner2.user_id', '$vip2.user_id$'))

    condition.add(inner_condition)

    assert_equal('"$nexists": { "joins": [], "where": {"inner.user_id" : "$vip.user_id$","$exists": { "joins": [], "model": 54545, "alias": "inner2", "where": {"inner2.user_id" : "$vip2.user_id$"}}}}', condition.to_record_string(Dynamicloud::API::Criteria::Condition::ROOT))
  end

  # Test a query
  def test_dynamic_helper
    data = {'name' => 'Eleazar'}
    assert_equal '{"name":"Eleazar"}', Dynamicloud::API::DynamicloudHelper.build_fields_json(data)

    data = {'name' => 'Eleazar', 'last_name' => 'gomez'}
    assert_equal '{"name":"Eleazar","last_name":"gomez"}', Dynamicloud::API::DynamicloudHelper.build_fields_json(data)

    data = {'name' => 'Eleazar', 'last_name' => 'gomez', 'hobbies' => [1, 2, 3]}
    assert_equal '{"name":"Eleazar","last_name":"gomez","hobbies":"1,2,3"}', Dynamicloud::API::DynamicloudHelper.build_fields_json(data)

    data = {'name' => 'Eleazar', 'last_name' => 'gomez', 'hobbies' => [1, nil, 2, 3, nil, nil]}
    assert_equal '{"name":"Eleazar","last_name":"gomez","hobbies":"1,2,3"}', Dynamicloud::API::DynamicloudHelper.build_fields_json(data)

    record = {'name' => 'Eleazar'}
    assert_equal ({'name' => 'Eleazar'}), (Dynamicloud::API::DynamicloudHelper.normalize_record record)

    record = {'name' => 'Eleazar', 'last_name' => 'gomez'}
    assert_equal ({'last_name' => 'gomez', 'name' => 'Eleazar'}), (Dynamicloud::API::DynamicloudHelper.normalize_record record)

    record = {'name' => 'Eleazar', 'last_name' => 'gomez', 'countries' => {'value' => %w(us ve ca), 'value02' => 'dummy'}}
    assert_equal ({'countries' => %w(us ve ca), 'last_name' => 'gomez', 'name' => 'Eleazar'}),
                 (Dynamicloud::API::DynamicloudHelper.normalize_record record)

    record = {'name' => 'Eleazar', 'last_name' => 'gomez', 'country' => {'value' => 'us'}}
    assert_equal ({'country' => 'us', 'last_name' => 'gomez', 'name' => 'Eleazar'}), (Dynamicloud::API::DynamicloudHelper.normalize_record record)

    projection = ['name']
    assert_equal '"columns": ["name"]', (Dynamicloud::API::DynamicloudHelper.build_projection projection)

    projection = ['count(name)']
    assert_equal '"columns": ["count(name)"]', (Dynamicloud::API::DynamicloudHelper.build_projection projection)

    data = {'name' => 'eleazar'}
    assert_equal ({'name' => 'eleazar'}), Dynamicloud::API::DynamicloudHelper.build_record(data)

    data = {'name' => 'Eleazar', 'last_name' => 'gomez', 'countries' => {'value' => %w(us ve ca), 'value02' => 'dummy'}}
    assert_equal ({'countries' => %w(us ve ca), 'last_name' => 'gomez', 'name' => 'Eleazar'}),
                 Dynamicloud::API::DynamicloudHelper.build_record(data)

    data = {
        'records' => [{'name' => 'Eleazar', 'last_name' => 'gomez', 'countries' => {'value' => %w(us ve ca), 'value02' => 'dummy'}}]
    }
    assert_equal [{'countries' => %w(us ve ca), 'last_name' => 'gomez', 'name' => 'Eleazar'}],
                 Dynamicloud::API::DynamicloudHelper.get_record_list(data)

    data = {
        'records' => [
            {'name' => 'Eleazar', 'last_name' => 'gomez', 'countries' => {'value' => %w(us ve ca), 'value02' => 'dummy'}},
            {'name' => 'Enrique', 'last_name' => 'gomez', 'countries' => {'value' => %w(us ve ca), 'value02' => 'dummy'}}
        ]
    }
    assert_equal [{'countries' => %w(us ve ca), 'last_name' => 'gomez', 'name' => 'Eleazar'},
                  {'countries' => %w(us ve ca), 'last_name' => 'gomez', 'name' => 'Enrique'}],
                 Dynamicloud::API::DynamicloudHelper.get_record_list(data)

    response = '{"records": {"total": 12, "size": 3, "records": [{"name": "eleazar"}, {"name": "enrique"}, {"name": "eleana"}]}}'
    record_results = Dynamicloud::API::DynamicloudHelper.build_record_results(response)

    assert_equal 3, record_results.fast_returned_size

    assert_equal 12, record_results.total_records

    assert_equal 3, record_results.records.size

    assert_equal [{'name' => 'eleazar'}, {'name' => 'enrique'}, {'name' => 'eleana'}], record_results.records

    joins = []

    assert_equal '"joins": []', Dynamicloud::API::DynamicloudHelper.build_join_tag(nil)

    assert_equal '"joins": []', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)

    joins.push Dynamicloud::API::Criteria::Conditions.left_join(234, 'user', 'user.id = language.userid')

    assert_equal '"joins": [{ "type": "left", "alias": "user", "target": "234", "on": "user.id = language.userid" }]', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)

    joins.push Dynamicloud::API::Criteria::Conditions.left_join(235, 'countries', 'user.id = countries.userid')

    assert_equal '"joins": [{ "type": "left", "alias": "user", "target": "234", "on": "user.id = language.userid" }, { "type": "left", "alias": "countries", "target": "235", "on": "user.id = countries.userid" }]', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)

    joins = []

    joins.push Dynamicloud::API::Criteria::Conditions.inner_join(234, 'user', 'user.id = language.userid')

    assert_equal '"joins": [{ "type": "inner", "alias": "user", "target": "234", "on": "user.id = language.userid" }]', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)

    joins = []

    joins.push Dynamicloud::API::Criteria::Conditions.right_join(234, 'user', 'user.id = language.userid')

    assert_equal '"joins": [{ "type": "right", "alias": "user", "target": "234", "on": "user.id = language.userid" }]', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)

    joins = []

    joins.push Dynamicloud::API::Criteria::Conditions.left_outer_join(234, 'user', 'user.id = language.userid')

    assert_equal '"joins": [{ "type": "left outer", "alias": "user", "target": "234", "on": "user.id = language.userid" }]', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)

    joins = []

    joins.push Dynamicloud::API::Criteria::Conditions.right_outer_join(234, 'user', 'user.id = language.userid')

    assert_equal '"joins": [{ "type": "right outer", "alias": "user", "target": "234", "on": "user.id = language.userid" }]', Dynamicloud::API::DynamicloudHelper.build_join_tag(joins)
  end
end