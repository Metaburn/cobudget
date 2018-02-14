class AnalyticsService
  def self.report
    self.new.report
  end

  def report
    {
      unconfirmed_user_count: unconfirmed_user_count,
      confirmed_user_count: confirmed_user_count,
      group_data: group_data
    }
  end

  private

    def unconfirmed_user_count
      User.where(confirmed_at: nil).count
    end

    def confirmed_user_count
      User.where.not(confirmed_at: nil).count
    end

    def group_data
      groups = Group.all
      groups.map do |group|
        {
          admins: group.members.joins(:memberships).where(memberships: {is_admin: true}).distinct.order(:created_at).as_json(only: [:name, :email]).map { |h| h.symbolize_keys },
          id: group.id,
          created_at: group.created_at,
          last_activity_at: group.last_activity_at,
          confirmed_member_count: group.members.where.not(confirmed_at: nil).count,
          unconfirmed_member_count: group.members.where(confirmed_at: nil).count,
          name: group.name,
          funded_bucket_count: group.buckets.where(status:'funded').count,
          total_allocations: group.total_allocations
        }
      end
    end
end
