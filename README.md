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

1. [Model](#recordmodel)
2. [Credential](#recordcredential)
3. [@Bind](#annotation-bind)
4. [DynamicProvider](#dynamicprovider)
  1. [DynamicProvider's methods](#methods)
5. [Query](#query-class)
  1. [RecordResults](#recordresults)
  - [Condition](#conditions-class)
  - [Conditions](#conditions-class)
  - [Next, Offset and Count methods](#next-offset-and-count-methods)
  - [Order by](#order-by)
  - [Group by and Projection](#group-by-and-projection)
  - [Functions as a Projection](#functions-as-a-projection)
6. [Update using selection](#update-using-selection)
7. [Delete using selection](#delete-using-selection)

These components will allow you to connect on Dynamicloud servers, authenticate and execute operations like *loadRecord*, *updateRecord*, *deleteRecord*, *get record's information according to selection*, *get record's information according to projection*, etc.  The next step is explain every components and how to execute operations.  
