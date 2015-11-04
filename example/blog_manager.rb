require 'dynamic_api'
require 'dynamic_criteria'

# This is the manager to execute all CRUD operations, queries, etc.
#
# @author Eleazar Gomez
# @version 1.0.0
# @since 10/29/15
class BlogManager
  CSK = 'csk#...'
  ACI = 'aci#...'

  USER_MODEL_ID = 111111111
  BLOG_MODEL_ID = 222222222
  POST_MODEL_ID = 333333333

  # This method will create a user in Dynamicloud model using username and email
  #
  # @param username username
  # @param email email
  def self.save_user(username, email)
    user = {}
    user['username'] = username
    user['email'] = email

    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})

    provider.save_record USER_MODEL_ID, user

    user
  end

  # This method saves a blog in Dynamicloud
  #
  # @param user_id owner id
  # @param name blog name
  # @param description blog description
  # @param category blog category
  def self.save_blog(user_id, name, description, category)
    blog = {}
    blog['blogname'] = name
    blog['blogdesc'] = description
    blog['blogcat'] = category
    blog['creatrid'] = user_id
    blog['createdt'] = Time.now.strftime('%y-%m-%d')

    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})

    provider.save_record BLOG_MODEL_ID, blog

    blog
  end

  # This method saves a post in Dynamicloud
  #
  # @param user_id owner id
  # @param blog_id blog ID
  # @param title title of this post
  # @param content content of this post
  def self.save_post(user_id, blog_id, title, content)
    post = {}
    post['postcont'] = content
    post['posttitl'] = title
    post['blogid'] = blog_id
    post['creatrid'] = user_id
    post['createdt'] = Time.now.strftime('%y-%m-%d')

    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})

    provider.save_record POST_MODEL_ID, post

    post
  end

  #This method deletes a user in Dynamicloud
  #
  #@param uid User ID
  def self.delete_user(uid)
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query POST_MODEL_ID
    query.add(Dynamicloud::API::Criteria::Conditions.equals('creatrid', uid))

    provider.delete query, POST_MODEL_ID

    delete_blogs uid

    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query USER_MODEL_ID
    query.add(Dynamicloud::API::Criteria::Conditions.equals('id', uid))

    provider.delete query, USER_MODEL_ID

  end

  # This method deletes the blogs associated to User ID
  #
  # @param uid User ID
  def self.delete_blogs(uid)
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})

    query = provider.create_query BLOG_MODEL_ID

    # Selection on creatrid (OwnerID)
    query.add(Dynamicloud::API::Criteria::Conditions.equals('creatrid', uid))

    # Get only the record id and bind with method setRecordId
    bids = query.get_results(['id as big']).records

    loop do
      unless bids.nil?
        bids.each do |record|
          delete_blog record['big']
        end

        # Get the next 15 blogs to delete them.
        bids = query.next.records
      end

      break if (bids.nil?) || (bids.length == 0)
    end
  end

  #This method deletes a blog in Dynamicloud
  #
  # @param bid Blog ID
  def self.delete_blog(bid)
    delete_posts bid

    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query BLOG_MODEL_ID
    query.add(Dynamicloud::API::Criteria::Conditions.equals('id', bid))

    provider.delete query, BLOG_MODEL_ID
  end

  #This method deletes the post associated to Blog ID
  #
  #@param bid Blog ID
  def self.delete_posts(bid)
    provider = Dynamicloud::API::DynamicProvider.new({:csk => CSK, :aci => ACI})
    query = provider.create_query POST_MODEL_ID
    query.add(Dynamicloud::API::Criteria::Conditions.equals('blogid', bid))

    provider.delete query, POST_MODEL_ID
  end
end