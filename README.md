# Dynamicloud Ruby API v1.0.0 (BETA)
This Ruby API  helps you to use the power of Dynamicloud.  This API follows our Rest documentation to execute CRUD operations according to http methods.

#Requirements

Ruby SDK 2.1.5 and later, you can download it on [Ruby  site](https://www.ruby-lang.org/en/downloads/ "Download Ruby")

#Main files

- You can install this gem in your system using RubyGems command 'gem install dynamicloud' or put in your gemfile the following: gem 'dynamicloud', '~> 1.0'
- **example/blog-test**

#Rubydoc

To read the Ruby API documentation click [here](http://www.dynamicloud.org/rdoc/index.html "Dynamicloud Ruby API documentation")

# Getting started

This API provides components to execute operations on [Dynamicloud](http://www.dynamicloud.org/ "Dynamicloud") servers.  The main components and methods are the followings:

1. [Model](#model)
2. [Credential](#credential)
3. [DynamicProvider](#dynamicprovider)
  1. [DynamicProvider's methods](#methods)
4. [Query](#query-class)
  1. [RecordResults](#recordresults)
  - [Condition](#conditions-class)
  - [Conditions](#conditions-class)
  - [Next, Offset and Count methods](#next-offset-and-count-methods)
  - [Order by](#order-by)
  - [Group by and Projection](#group-by-and-projection)
  - [Functions as a Projection](#functions-as-a-projection)
5. [Update using selection](#update-using-selection)
6. [Delete using selection](#delete-using-selection)

These components will allow you to connect on Dynamicloud servers, authenticate and execute operations like *loadRecord*, *updateRecord*, *deleteRecord*, *get record's information according to selection*, *get record's information according to projection*, etc.  The next step is explain every components and how to execute operations.  

# Model

To load records in this API you're going to use a **Model ID**.  Every record belongs to a Model.

#Credential

To gain access in Dynamicloud servers you need to provide the API keys.  These APIs ware provided at moment of your registration.

#DynamicProvider
**Dynamicloud::API::DynamicProvider**

**DynamicProvider** provides important methods and can be used as follow:
```ruby
module Dynamicloud
  class API
    class DynamicProvider
    def initialize(credential)
      @credential = credential
    end
    .
    .
    .
  end
end
```

**First, let's explain the constructor of this class:**
 ```ruby
def initialize(credential)
 ```
This constructor receives a hash with the credential to gain access.  The credential hash is composed of Client Secret Key (CSK) and Application Client ID (ACI), these keys were provided at moment of your registration.
 
#Methods

**Load Record**
```ruby
def load_record(rid, mid)
```
This method loads a record according to rid *(RecordID)* in model *(ModelID)*.

**For example, a call of this method would be:**
 ```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})
 
record = provider.load_record rid, mid

puts record['email']
```

**Save Record**
 ```ruby
def save_record(mid, data)
```
This method saves a record (hash) with all the data.

**For example, a call of this method would be:**
 ```ruby

record = {}
record['name'] = 'Eleazar'
record['last_name'] = 'Gomez'
record['email'] = 'rmail@dynamicloud.org'

provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

provider.save_record mid, record #This method will fill the key 'rid' in record hash with the record ID

puts record['rid']
```

**Update Record**
 ```ruby
def update_record(mid, data)
```
This method updates the record (data['rid'])

**For example, a call of this method would be:**
 ```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})
 
record = provider.load_record rid, mid

record['email'] = 'email@dynamicloud.org'

provider.update_record mid, record
```

**Delete Record**
 ```ruby
def delete_record(mid, rid)
```
This method deletes a record from theModel

**For example, a call of this method would be:**
 ```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})
 
provider.delete_record mid, rid
```

**Create query**
 ```ruby
def create_query(mid)
```
This method returns a Query **(Dynamicloud::API::RecordQuery)**  to get records according specific conditions.

**For example, a call of this method would be:**
 ```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})
 
query = provider.create_query mid
```

#Query class
**Dynamicloud::API::RecordQuery**

This class provides a set of methods to add conditions, order by and group by clauses, projections, etc.

```ruby
def add(condition)
def asc
def desc
def set_count(count)
def set_offset(offset)
def get_results(projection = nil)
def order_by(attribute)
def group_by(attribute)
def next
```

With the Query object we can add conditions like EQUALS, IN, OR, AND, GREATER THAN, LESSER THAN, etc.  The query object is mutable and every call of its methods will return the same instance.

#RecordResults
**Dynamicloud::API::RecordResults**

**This class provides three methods:**
- **total_records:** The total records in RecordModel
- **fast_returned_size:** The returned size of records that have matched with Query conditions
- **records:** A list of records.

**The uses of this class would be as a follow:**

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query mid
results = query.add(Dynamicloud::API::Criteria::Conditions.not_equals('email', 'email@dynamicloud.org')).get_results

puts results.fast_returned_size
puts results.total_records
puts results.records.length
```

#Conditions class

This class provides a set of methods to build conditions and add them in query object
```ruby
def self.and(left, right)
def self.or(left, right)
def self.in(left, values)
def self.not_in(left, values)
def self.not_in(left, values)
def self.like(left, like)
def self.not_like(left, like)
def self.equals(left, right)
def self.not_equals(left, right)
def self.greater_equals(left, right)
def self.greater_than(left, right)
def self.lesser_than(left, right)
def self.lesser_equals(left, right)
```

To add conditions to a Query object it must call the add method **(query.add(condition))**

**For example:**

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = (provider.create_query(mid)).add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))
```

Every call of add method in object Query will put the Condition in a ordered list of conditions, that list will be joint as a AND condition.  So, if you add two conditions as follow:

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))
query.add(Dynamicloud::API::Criteria::Conditions.equals('age', 33))
```

These two calls of add method will produce something like this:

name like 'Eleazar%' **AND** age = 33

Query class provides a method called **get_results(projection = nil)**, this method will execute a request using the *ModelID*, *Conditions* and the *projection* (if was passed). The response from Dynamicloud will be encapsulated in the object **RecordResults**

#Next, Offset and Count methods

Query class provides a method to walk across the records of a Model.  Imagine a model with a thousand of records, obviously you shouldn't load the whole set of records, you need to find a way to load a sub-set by demand.

The method to meet this goal is **next**.  Basically, the next method will increase the offset automatically and will execute the request with the previous conditions. By default, offset and count will have 0 and 15 respectively.

**The uses of this method would be as a follow:**

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))
query.add(Dynamicloud::API::Criteria::Conditions.equals('age', 33))

results = query.get_results
results.records.each do |record|
  puts record['email']
end

results = query.next

#Loop with the next 15 records
results.records.each do |record|
  puts record['email']
end
```

If you want to set an **offset** or **count**, follow this guideline:

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))
query.add(Dynamicloud::API::Criteria::Conditions.equals('age', 33))

#Every call will fetch max 10 records and will start from eleventh record.
query.set_offset(1).set_count(1)

results = query.get_results
results.records.each do |record|
  String email = record['email']
end

#This call will fetch max 10 records and will start from twenty first record.
results = query.next

#Loop through the next 10 records
results.records.each do |record|
  email = record['email']
end
```

#Order by

To fetch records ordered by a specific field, the query object provides the method **order_by**.  To sort the records in a descending/ascending order you must call asc/desc method after call order_by method.

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))
query.add(Dynamicloud::API::Criteria::Conditions.equals('age', 33))

#Every call will fetch max 10 records and will start from eleventh record.
query.set_count(10).set_offset(1).order_by('email').asc # Here you can call desc method

results.records.each do |record|
  email = record['email']
end
```

#Group by and Projection

To group by a specifics fields, the query object provides the method **group_by**.  To use this clause, you must set the projection to the query using **set_projection** method.

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))
query.add(Dynamicloud::API::Criteria::Conditions.equals('age', 33))

#Every call will fetch max 10 records and will start from eleventh record.
query.set_count(10).set_offset(1).order_by('email').asc # Here you can call desc method

#These are the fields in your projection
query.group_By('name, email');

results = query.get_results(['name', 'email']);
results.records.each do |record|
  email = record['email']
end
```

#Functions as a Projection

Query object provides the setProjection method to specify the fields you want to fetch in a query.  In this method you can set the function you want to call. Every function must has an alias to bind it with a setMethod in BoundInstance object.

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)

query.add(Dynamicloud::API::Criteria::Conditions.like('name', 'Eleaz%'))

record = query.get_results(['avg(age) as average']).records[0]
average = record['average']
```

#Update using selection

There are situations where you need to update records using a specific selection.

In this example we are going to update the **name** where age > 24

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.greater_than('age', 24))

# This method will use the data hash and the query object to update only the records that match with the selection.

provider.update query, {'name' => 'Eleazar'}
```

#Delete using selection

There are situations where you need to delete records using a specific selection.

In this example we are going to delete the records where age > 24

```ruby
provider = Dynamicloud::API::DynamicProvider.new({:csk => 'csk#...', :aci => 'aci#...'})

query = provider.create_query(mid)
query.add(Dynamicloud::API::Criteria::Conditions.greater_than('age', 24))

# This method will delete the records that match with the selection.

provider.delete query
```
