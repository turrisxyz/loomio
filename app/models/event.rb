class Event < ActiveRecord::Base
  KINDS = %w[new_discussion discussion_description_edited new_comment new_motion new_vote motion_blocked
             motion_closing_soon motion_closed motion_close_date_edited membership_requested user_added_to_group comment_liked user_mentioned]

  has_many :notifications, :dependent => :destroy
  belongs_to :eventable, :polymorphic => true
  belongs_to :user

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  attr_accessible :kind, :eventable, :user, :discussion_id

  def self.new_discussion!(discussion)
    activity = create!(:kind => "new_discussion", :eventable => discussion,
      :discussion_id => discussion.id)
    discussion.group_users.each do |user|
      unless user == discussion.author
        activity.notifications.create! :user => user
      end
    end
    activity
  end

  def self.discussion_description_edited!(discussion, editor)
    activity = create!(:kind => "discussion_description_edited", :eventable => discussion,
      :discussion_id => discussion.id, :user => editor)
    activity
  end

  def self.new_comment!(comment)
    activity = create!(:kind => "new_comment", :eventable => comment,
      :discussion_id => comment.discussion.id)
    comment.discussion_participants.each do |user|
      unless user == comment.user
        activity.notifications.create! :user => user
      end
    end
    activity
  end

  def self.new_motion!(motion)
    activity = create!(:kind => "new_motion", :eventable => motion,
      :discussion_id => motion.discussion.id)
    motion.group_users.each do |user|
      unless user == motion.author
        activity.notifications.create! :user => user
      end
    end
    activity
  end

  def self.motion_closed!(motion, closer)
    activity = create!(:kind => "motion_closed", :eventable => motion, :user => closer,
      :discussion_id => motion.discussion.id)
    motion.group_users.each do |user|
      unless user == closer
        activity.notifications.create! :user => user
      end
    end
    activity
  end

  def self.motion_closing_soon!(motion)
    event = create!(:kind => "motion_closing_soon", :eventable => motion)
    motion.group_users.each do |user|
      event.notifications.create! :user => user
    end
    event
  end

  def self.motion_close_date_edited!(motion, closer)
    activity = create!(:kind => "motion_close_date_edited", :eventable => motion,
      :user => closer,  :discussion_id => motion.discussion.id)
    activity
  end

  def self.new_vote!(vote)
    activity = create!(:kind => "new_vote", :eventable => vote,
      :discussion_id => vote.motion.discussion.id)
    begin
      unless vote.user == vote.motion_author
        activity.notifications.create! :user => vote.motion_author
      end
      unless vote.user == vote.discussion_author
        activity.notifications.create! :user => vote.discussion_author
      end
    rescue ActiveRecord::RecordInvalid => error
      # Catches error if we are trying to create duplicate notifications for
      # the same user (i.e. if motion author and discussion author are same person)
      raise unless error.message =~ /User has already been taken/
    end
    activity
  end

  def self.motion_blocked!(vote)
    event = create!(:kind => "motion_blocked", :eventable => vote,
      :discussion_id => vote.motion.discussion.id)
    vote.group_users.each do |user|
      unless user == vote.user
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.membership_requested!(membership)
    event = create!(:kind => "membership_requested", :eventable => membership)
    membership.group_admins.each do |admin|
      event.notifications.create! :user => admin
    end
    event
  end

  def self.user_added_to_group!(membership)
    event = create!(:kind => "user_added_to_group", :eventable => membership)
    event.notifications.create! :user => membership.user
    # Send email only if the user has already accepted invitation to Loomio
    if membership.user.accepted_or_not_invited?
      UserMailer.added_to_group(membership).deliver
    end
    event
  end

  def self.comment_liked!(comment_vote)
    event = create!(:kind => "comment_liked", :eventable => comment_vote)
    unless comment_vote.user == comment_vote.comment_user
      event.notifications.create! :user => comment_vote.comment_user
    end
    event
  end

  def self.user_mentioned!(comment, mentioned_user)
    event = create!(:kind => "user_mentioned", :eventable => comment)
    unless mentioned_user == comment.user
      event.notifications.create! :user => mentioned_user
    end
  end
end
