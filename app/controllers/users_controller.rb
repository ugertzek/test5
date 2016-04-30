class UsersController < ApplicationController

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end


   #DELETE /users/1
   #DELETE /users/1.json
  def dismiss
    @user = User.find(params[:user])
    @user.dismiss(params[:twitter_id])
    respond_to do |format|
      format.html { redirect_to '/users/'+@user.id.to_s, notice: 'Follower is dismissed.' }
      format.json { head :no_content }
    end
  end

  #PUT /users/1
  #PUT /users/1.json
  def op
    @user = User.find(params[:user])
    case params[:op]
      when 'sayhello'
        @user.say_hello(params[:screen_name])
        msg = 'Message was sent to the user.'
      when 'follow'
        @user.follow_user(params[:twitter_id])
        msg = "User #{params[:screen_name].to_s} is now being followed."
      when 'unfollow'
        @user.unfollow_user(params[:twitter_id])
        msg = "User #{params[:screen_name].to_s} is now being unfollowed."
      else
        msg = 'Invalid operation.'
    end
    respond_to do |format|
      format.html { redirect_to @user, notice: msg }
      format.json { head :no_content }
    end
  end



end
