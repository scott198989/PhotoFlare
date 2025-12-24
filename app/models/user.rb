class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts
  has_many :stories, dependent: :destroy
  has_many :story_views, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'actor_id', dependent: :destroy
  has_one_attached :profile_pic

  has_many :likes

  has_many :comments

  has_many :follow_requests, -> {where(accepted: false) }, class_name: "Follow", foreign_key: "followed_id"

  has_many :accepted_recieved_requests, -> {where(accepted: true) }, class_name: "Follow", foreign_key: "followed_id"

  has_many :accepted_sent_requests, -> {where(accepted: true) }, class_name: "Follow", foreign_key: "follower_id"

  # has_many :recieved_requests, class_name: "Follow", foreign_key: "followed_id"
  # has_many :sent_requests, class_name: "Follow", foreign_key: "follower_id"
  has_many :waiting_sent_requests, -> {where(accepted: false) }, class_name: "Follow", foreign_key: "follower_id"

  has_many :followers, through: :accepted_recieved_requests, source: :follower
  has_many :followings, through: :accepted_sent_requests, source: :followed
  has_many :waiting_followings, through: :waiting_sent_requests, source: :followed

  def follow(user)
    Follow.create(follower: self, followed: user)
  end

  def unfollow(user)
    self.accepted_sent_requests.find_by(followed: user)&.destroy
  end

  def cancel_request(user)
    self.waiting_sent_requests.find_by(followed: user)&.destroy
  end

  # Stories helpers
  def active_stories
    stories.active.recent
  end

  def has_active_story?
    stories.active.exists?
  end
end
