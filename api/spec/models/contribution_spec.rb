require 'rails_helper'

RSpec.describe Contribution, :type => :model do
  describe "#create" do
    context "amount would overdraft member" do
      it "does not validate record and throws error" do
        make_user_group_member
        create(:allocation, user: user, group: group, amount: 100)
        expect{create(:contribution, user: user, group: group, amount: 101)}.to raise_error
      end
    end
  end

  describe "#lower_amount_if_exceeds_target" do
    it "changes amount to exactly reach target, if initial amount exceeds it" do
      bucket = create(:bucket, group: group, target: 500)
      bucket.update(status: 'live')
      membership = make_user_group_member
      create(:allocation, user: membership.member, group: membership.group, amount: 10000)

      contribution1 = create(:contribution, amount: 200, user: user, bucket: bucket)
      contribution2 = create(:contribution, amount: 600, user: user, bucket: bucket)
      contribution3 = create(:contribution, amount: 600, user: user, bucket: bucket)

      bucket.reload
      contribution1.reload
      contribution2.reload
      contribution3.reload

      expect(bucket.total_contributions).to eq(500)
      expect(contribution1.amount).to eq(200)
      expect(contribution2.amount).to eq(300)
      expect(contribution3.amount).to eq(0)
    end
  end

  describe "#update_bucket_status_if_funded" do
    it "updates bucket's status to 'funded' if status is 'live' and target is met" do
      bucket = create(:bucket, target: 420)
      bucket.update(status: 'live')
      create(:contribution, bucket: bucket, amount: 100)
      create(:contribution, bucket: bucket, amount: 200)
      create(:contribution, bucket: bucket, amount: 120)
      bucket.reload
      expect(bucket.status).to eq('funded')
    end
  end
end
