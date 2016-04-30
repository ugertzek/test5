class Follower < ActiveRecord::Base
  #
  # Table name: followers
  #
  #  id                         :integer   not null, primary key
  #  user_id                    :string    not null, foreign key
  #  displayed_as_follower      :boolean
  #  displayed_as_unfollower    :boolean
  #  dismissed                  :boolean
  #  follow_date                :datetime
  #  unfollow_date              :datetime
  #  twitter_id : string
  #
  belongs_to :user
  class << self


  end

end