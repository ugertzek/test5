class User < ActiveRecord::Base

#
# Table name: users
#
#  id         :integer          not null, primary key
#  uid        :string
#  name       :string
#  image_url  :string
#  token      :string
#  secret     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
  has_many :followers, :dependent => :destroy
  accepts_nested_attributes_for :followers
  attr_accessor :is_new

  # @return [@followers]
  def get_followers()
    @followers = self.followers.select(:twitter_id).where("displayed_as_follower=0").where("dismissed=0").where("follow_date>unfollow_date").order('follow_date desc').first(3)
    if @followers.nil?
      []
    else
      followers_ids = @followers.collect{|x| x['twitter_id'].to_i}
      self.followers.where('twitter_id in (?)',followers_ids).update_all(displayed_as_follower:true)
      self.get_users_info(followers_ids)
    end
  end

  def get_unfollowers()
    @unfollowers = self.followers.select(:twitter_id).where("displayed_as_unfollower=0").where("dismissed=0").where("follow_date<unfollow_date").order('follow_date desc').first(3)
    if @unfollowers.nil?
      []
    else
      unfollowers_ids = @unfollowers.collect{|x| x['twitter_id'].to_i}
      self.followers.where('twitter_id in (?)',unfollowers_ids).update_all(displayed_as_unfollower:true)
      self.get_users_info(unfollowers_ids)
    end
  end

  def get_users_info(twitter_ids)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Communit2::Application.config.consumer_key
      config.consumer_secret     = Communit2::Application.config.consumer_secret
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
    followers = client.users(twitter_ids).map { |f| {:twitter_id => f.id, :screen_name => f.screen_name,:followers_count =>f.followers_count, :profile_image_url => f.profile_image_url,:name => f.name } }
    followers
  end

  def get_users_followers_count()
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Communit2::Application.config.consumer_key
      config.consumer_secret     = Communit2::Application.config.consumer_secret
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
    user_info = client.users(self.uid.to_i)
    user_info[0].attrs[:followers_count]
  end

  # @param [Object] user_id
  # @param [Object] twitter_id
  def dismiss(twitter_id)
    self.followers.where("twitter_id =?",twitter_id).update_all(dismissed:1)
  end

  def follow_user(twitter_id)
    #TODO: grabs key and secret from config
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Communit2::Application.config.consumer_key
      config.consumer_secret     = Communit2::Application.config.consumer_secret
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
    client.follow(twitter_id.to_i)
  end

  def unfollow_user(twitter_id)
    #TODO: grabs key and secret from config
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Communit2::Application.config.consumer_key
      config.consumer_secret     = Communit2::Application.config.consumer_secret
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
    client.unfollow(twitter_id.to_i)
  end


  # @param [Object] to_user_screen_name
  def say_hello(to_user_screen_name)
    #usage - postHiMessage(user,'GetEventsBot')
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Communit2::Application.config.consumer_key
      config.consumer_secret     = Communit2::Application.config.consumer_secret
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
    message = 'Hi @'+to_user_screen_name+' how are you today?'
    client.update(message)
  end

  class << self
    def from_twitter(auth_hash)
      logger.debug 'Inside Users'
      user = find_or_create(auth_hash['uid'])
      logger.debug 'After create'
      user.name = auth_hash['info']['name']
      user.image_url = auth_hash['info']['image']
      user.token = auth_hash['credentials']['token']
      user.secret = auth_hash['credentials']['secret']
      user.updated_at = Time.now
      user.save!
      user
    end


    private



#find_or_create_by does not work in this version
    def find_or_create(uid)
      is_new = false
      @user = User.where("uid =?",uid).first
      is_new = true if @user.nil?
      @user = User.new() if @user.nil?
      @user.uid = uid
      @user.is_new = is_new
      @user
    end

#find_or_create_by does not work in this version
    def find_user_by_id(id)
      User.find(id)
    end

    def get_social_location_for(provider, location_hash)
      case provider
        when 'linkedin'
          location_hash['name']
        else
          location_hash
      end
    end

    def get_social_url_for(provider, urls_hash)
      case provider
        when 'linkedin'
          urls_hash['public_profile']
        else
          urls_hash[provider.capitalize]
      end
    end
  end


end
