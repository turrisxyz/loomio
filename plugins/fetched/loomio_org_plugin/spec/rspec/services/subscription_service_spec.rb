require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

describe SubscriptionService do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:user4) { create(:user) }
  let!(:user5) { create(:user) }
  let!(:group) { build(:group, creator: user1) }
  let!(:group2) { build(:group, creator: user1) }

  let(:discussion) { DiscussionService.create(discussion: build(:discussion, author: user1, group: group), actor: user1).eventable }

  let(:comment1) { CommentService.create(comment: build(:comment, discussion: discussion, author: user2), actor: user2).eventable }
  let(:comment2) { CommentService.create(comment: build(:comment, discussion: discussion, author: user3), actor: user3).eventable }
  let(:comment3) { CommentService.create(comment: build(:comment, discussion: discussion, author: user4), actor: user4).eventable }
  let(:comment4) { CommentService.create(comment: build(:comment, discussion: discussion, author: user5), actor: user5).eventable }

  describe 'count_members' do
    before do
      GroupService.create(group: group, actor: user1)
      GroupService.create(group: group2, actor: user1)
      [user1, user2, user3, user4, user5].each { |user| group.add_member! user }
      [user1, user2, user3, user4, user5].each { |user| group2.add_member! user }
      @subscription = group.subscription
      group2.update(subscription_id: @subscription.id)
      @subscription.update(chargify_subscription_id: 1)
      discussion
    end

    describe 'unique users per subscription' do
      it 'count_active_members' do
        comment1
        comment2
        comment3
        comment4
        expect(@subscription.count_active_members).to eq 5
      end

      it 'count_accepted_members' do
        expect(@subscription.count_accepted_members).to eq 5
      end
    end

    describe 'day 0' do
      it 'trial' do
        @subscription.update(plan: 'trial', state: 'trialing')
        expect(@subscription.count_members).to eq 1
      end

      it 'pp-basic-monthly' do
        @subscription.update(state: 'active', plan: 'pp-basic-monthly')
        expect(@subscription.count_members).to eq 5
      end

      it 'pp-basic-annual' do
        @subscription.update(state: 'active', plan: 'pp-basic-annual')
        expect(@subscription.count_members).to eq 5
      end

      it 'pp-community-annual' do
        @subscription.update(state: 'active', plan: 'pp-community-annual')
        expect(@subscription.count_members).to eq 5
      end

      it 'ap-active-monthly' do
        renewed_at = 1.hour.ago
        @subscription.update(state: 'active', plan: 'ap-active-monthly', renewed_at: renewed_at, renews_at: renewed_at + 1.month)
        expect(@subscription.count_members).to eq 1
      end

      it 'ap-active-annual' do
        @subscription.update(state: 'active', plan: 'ap-active-annual')
        expect(@subscription.count_members).to eq 1
      end

      it 'ap-community-annual' do
        @subscription.update(state: 'active', plan: 'ap-community-annual')
        expect(@subscription.count_members).to eq 1
      end

    end

    describe 'after 1 month' do
      before do
        travel_to(1.month.from_now + 1.day)
        comment1
      end

      after do
        travel_back
      end

      it 'trial' do
        @subscription.update(state: 'trialing', plan: 'trial')
        expect(@subscription.count_members).to eq 1
      end

      it 'pp-basic-monthly' do
        @subscription.update(state: 'active', plan: 'pp-basic-monthly')
        expect(@subscription.count_members).to eq 5
      end

      it 'pp-basic-annual' do
        @subscription.update(state: 'active', plan: 'pp-basic-annual')
        expect(@subscription.count_members).to eq 5
      end

      it 'pp-community-annual' do
        @subscription.update(state: 'active', plan: 'pp-community-annual')
        expect(@subscription.count_members).to eq 5
      end

      it 'ap-active-monthly' do
        renewed_at = 1.hour.ago
        @subscription.update(state: 'active', plan: 'ap-active-monthly', renewed_at: renewed_at, renews_at: renewed_at + 1.month)
        expect(@subscription.count_members).to eq 1
      end

      it 'ap-active-annual' do
        @subscription.update(state: 'active', plan: 'ap-active-annual')
        expect(@subscription.count_members).to eq 1
      end

      it 'ap-community-annual' do
        @subscription.update(state: 'active', plan: 'ap-community-annual')
        expect(@subscription.count_members).to eq 1
      end
    end
  end

  describe 'update_member_counts' do
    before do
      GroupService.create(group: group, actor: user1)
      [user1, user2, user3, user4, user5].each { |user| group.add_member! user }
      @subscription = group.subscription
      @subscription.update(chargify_subscription_id: 1)
      discussion
    end

    describe 'pp-basic-monthly' do
      it "same day of purchase" do
        renewed_at = 5.minutes.ago
        @subscription.update(state: 'active', plan: 'pp-basic-monthly', renewed_at: renewed_at, renews_at: renewed_at + 1.month, members_count: 0)
        expect(SubscriptionService).to receive(:update_chargify_component_allocation).with(chargify_subscription_id: @subscription.chargify_subscription_id, plan: @subscription.plan, count: 5).and_return(double({ code: 200 }))
        SubscriptionService.update_member_counts
      end
    end

    describe 'pp-basic-annual' do
      it "not 1st of month" do
        travel_to(Date.today.at_end_of_month) do
          renewed_at = 5.minutes.ago
          @subscription.update(state: 'active', plan: 'pp-basic-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.month, members_count: 0)
          expect(SubscriptionService).not_to receive(:update_chargify_component_allocation)
          SubscriptionService.update_member_counts
        end
      end

      it "1st of month" do
        travel_to(Date.today.at_beginning_of_month.next_month) do
          renewed_at = 5.minutes.ago
          @subscription.update(state: 'active', plan: 'pp-basic-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.month, members_count: 0)
          expect(SubscriptionService).to receive(:update_chargify_component_allocation).with(chargify_subscription_id: @subscription.chargify_subscription_id, plan: @subscription.plan, count: 5).and_return(double({ code: 200 }))
          SubscriptionService.update_member_counts
        end
      end

      it "1st of month no change" do
        travel_to(Date.today.at_beginning_of_month.next_month) do
          renewed_at = 5.minutes.ago
          @subscription.update(state: 'active', plan: 'pp-basic-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.month)
          @subscription.update(members_count: @subscription.count_members)
          expect(SubscriptionService).not_to receive(:update_chargify_component_allocation).with(chargify_subscription_id: @subscription.chargify_subscription_id, plan: @subscription.plan, count: 5)
          SubscriptionService.update_member_counts
        end
      end
    end

    describe 'ap-active-monthly' do
      it "same day of purchase" do
        renewed_at = 5.minutes.ago
        @subscription.update(state: 'active', plan: 'ap-active-monthly', renewed_at: renewed_at, renews_at: renewed_at + 1.month, members_count: 0)
        expect(SubscriptionService).to receive(:update_chargify_component_allocation).with(chargify_subscription_id: @subscription.chargify_subscription_id, plan: @subscription.plan, count: 1).and_return(double({ code: 200 }))
        SubscriptionService.update_member_counts
      end
    end

    describe 'ap-active-annual' do
      it "not beginning of month" do
        renewed_at = 5.minutes.ago
        travel_to(Date.today.at_end_of_month) do
          @subscription.update(state: 'active', plan: 'ap-active-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.year, members_count: 0)
          expect(SubscriptionService).not_to receive(:update_chargify_component_allocation)
          SubscriptionService.update_member_counts
        end
      end

      it "at beginning of month" do
        travel_to(Date.today.next_month.at_beginning_of_month) do
          renewed_at = 1.month.ago
          @subscription.update(state: 'active', plan: 'ap-active-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.year, members_count: 0, chargify_subscription_id: 123)
          expect(SubscriptionService).to receive(:update_chargify_component_allocation).with(chargify_subscription_id: @subscription.chargify_subscription_id, plan: @subscription.plan, count: 1).and_return(double({ code: 200 }))
          SubscriptionService.update_member_counts
        end
      end
    end

    describe 'ap-community-annual' do
      it "not beginning of month" do
        renewed_at = 5.minutes.ago
        travel_to(Date.today.at_end_of_month) do
          @subscription.update(state: 'active', plan: 'ap-community-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.year, members_count: 0)
          expect(SubscriptionService).not_to receive(:update_chargify_component_allocation)
          SubscriptionService.update_member_counts
        end
      end

      it "at beginning of month" do
        travel_to(Date.today.next_month.at_beginning_of_month) do
          renewed_at = 1.month.ago
          @subscription.update(state: 'active', plan: 'ap-community-annual', renewed_at: renewed_at, renews_at: renewed_at + 1.year, members_count: 0)
          expect(SubscriptionService).to receive(:update_chargify_component_allocation).with(chargify_subscription_id: @subscription.chargify_subscription_id, plan: @subscription.plan, count: 1).and_return(double({ code: 200 }))
          SubscriptionService.update_member_counts
        end
      end
    end
  end
end
