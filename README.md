# Dynamicloud Ruby API v1.0.0
This Ruby API  helps you to use the power of Dynamicloud.  This API follows our Rest documentation to execute CRUD operations according to http methods.

#Requirements

Ruby SDK 2.1.5 and later, you can download it on [Ruby  site](https://www.ruby-lang.org/en/downloads/ "Download Ruby")

#Main files

- **dist/dynamicloud-1.0.0.gem**
- **example/blog-test**

#Rubydoc

To read the ruby documentation click [here](http://www.dynamicloud.org/ "Dynamicloud Ruby documentation")

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
