# Blog Test

This example is a test case to show how to use the Dynamicloud Ruby API.  The example is an interactive (REPL) program that will ask the actions to create, list and delete records.

**Models that you need to create to test this example:**

####Model **'User'**

**Fields:**
- username (Textfield)
- email (Textfield)

####Model **'Blog'**

**Fields:**

- blogname (Textfield)
- blogdesc (Textarea)
- blogcat (Combobox), items:
  - Technology (tech)
  -	Medical (med)
  -	Science (sci)
  -	General (gen)
- createdt (Date)
- creatrid (Numeric)

####Model **'Post'**

**Fields:**
- postcontent (Textarea)
- posttitl (Textfield)
- blogid (Numeric)
- createdt (Date)
- creatrid (Numeric)


After creating models, you have to set the Client Secret Key (csk) and Application Client Id (aci) in source code berfore you compile it.

**The name of the class where you have to set the csk and aci is BlogManager:**

**Variables:**

```ruby
  CSK = 'csk#...'
  ACI = 'aci#...'
```

Now, execute **ruby main.rb** command to show the available options:

```ruby
require 'optparse'
require_relative 'blog_manager'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = 'Dynamicloud'
  opt.separator ''
  opt.separator 'Options'

  opt.on('-u', "--u 'Username','Email'", Array, 'Create a user.  You must surround with single quote the Username and Email') do |o|
    options[:opt] = 'u'
    options[:data] = o
  end

  opt.on('-b', "--b 'Owner ID (UserID)','Name','Description','Category - Technology(tech),Medical(med),Science(sci),General(gen)'", Array, 'Create a Blog.  You must surround with single quote the Owner ID, Name, Description and Category') do |o|
    options[:opt] = 'b'
    options[:data] = o
  end

  opt.on('-lb', "--lb 'Owner ID (UserID)'", Array, 'Lists blogs of user.  You must surround with single quote the Owner ID (UserID)') do |o|
    options[:opt] = 'lb'
    options[:userid] = o
  end

  opt.on('-p', "--p 'Owner ID (UserID)','Blog ID','Post Title','Post Content'", Array, 'Post in a Blog.  You must surround with single quote the Owner ID (UserID), Blog ID, Post title and Post Content') do |o|
    options[:opt] = 'p'
    options[:data] = o
  end

  opt.on('-d', '--d UserID', Array, 'Delete User') do |o|
    options[:opt] = 'd'
    options[:data] = o
  end
end

opt_parser.parse!

case options[:opt]
  when 'u'
    username = options[:data][0]
    email = options[:data][1]

    puts 'Creating user...'
    user = BlogManager.save_user username, email
    puts "User has been created with user id -> #{user['rid']}"
  when 'b'
    user_id = options[:data][0]
    name = options[:data][1]
    description = options[:data][2]
    category = options[:data][3]

    puts 'Creating blog...'
    user = BlogManager.save_blog user_id, name, description, category
    puts "Blog has been created with blog id -> #{user['rid']}"
  when 'p'
    user_id = options[:data][0]
    blog_id = options[:data][1]
    title = options[:data][2]
    content = options[:data][3]

    puts 'Creating post...'
    post = BlogManager.save_post user_id, blog_id, title, content
    puts "Post '#{post['rid']}' has been posted at blog id -> #{blog_id}"
  when 'd'
    user_id = options[:data][0]

    puts 'Deleting user...'
    BlogManager.delete_user user_id
    puts 'User has been deleted'
  when 'lb'
    puts 'Getting blogs of user id (' + options[:userid] + ')...'
  else
    puts opt_parser
end
```
