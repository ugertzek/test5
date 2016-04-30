class SessionsController < ApplicationController
  def create
    begin
      auth_hash = request.env['omniauth.auth']
      @user = User.from_twitter(request.env['omniauth.auth'])
      followers_count = @user.get_users_followers_count()
      getTwitterFollowers(@user,followers_count)
      session[:user_id] = @user.id
    rescue
     flash[:warning] = "There was an error while trying to authenticate you..."
    end
    redirect_to '/users/'+@user.id.to_s
  end

  def getTwitterFollowers(user,followers_count)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Communit2::Application.config.consumer_key
      config.consumer_secret     = Communit2::Application.config.consumer_secret
      config.access_token        = user.token
      config.access_token_secret = user.secret
    end
    limit_count_exceeded = false
    initial_followers_count = [1,(0.1*followers_count).ceil].max
    #Collecting the followers that were already registered
    old_array_followers = user.followers.select('twitter_id').as_json.collect{|x| x['twitter_id']}
    followers_quota = 5000
    page_num = 1
    current_followers_ids = Array.new
    #Collecting the current followers
    begin
        current_followers = client.followers(:count => followers_quota)
    rescue Exception => e
        flash[:warning] = "Error in twitter call..."
        logger.debug "Error in twitter call: #{e}"
        return
    end
    begin
      followers_cnt = 0
      #about to begin processing followers
      begin
      current_followers.each do |f|
        followers_cnt = followers_cnt +1
        twitter_id = f.id.to_s
        @follower = user.followers.where("twitter_id =?",twitter_id).first
        #Add new followers to the DB
        if @follower.nil?
          @follower = Follower.new()
          @follower.twitter_id = twitter_id
          @follower.user_id = user.id
        end
        if user.is_new && followers_cnt>initial_followers_count
          @follower.displayed_as_follower = 1
        end
        #Updating most recent following date of a follower
        @follower.follow_date = user.updated_at
        #Collecting current followers ids
        current_followers_ids.push(twitter_id)
        @follower.save
      end
      rescue Exception => e
        limit_count_exceeded = true
        logger.debug "Error in twitter call"
        #We better keep going with what we already have
        flash[:warning] = "Error in twitter call..."
        logger.debug "Error in twitter call: #{e}"
      end
      begin
        if not limit_count_exceeded
          cursor = current_followers.attrs[:next_cursor]
        else
          break
        end
      rescue Exception => e
        flash[:warning] = "Error in twitter call..."
        logger.debug "Error in twitter call"
        #We better keep going with what we already have
        break if e.code==88
        flash[:warning] = "Error in twitter call..."
        logger.debug "Error in twitter call: #{e}"
      end
    end while cursor.nil? && cursor > 0
    #The set difference between old followers and current followers is the set of unfollowers
    unfollowers = old_array_followers-current_followers_ids
    #Updating the unfollowers
    user.followers.where('twitter_id in (?)',unfollowers).update_all(unfollow_date:user.updated_at)
  end

  def auth_failure
    redirect_to root_path
  end
end