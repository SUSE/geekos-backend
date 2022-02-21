class Api::MetaController < Api::BaseController
  def users
    newcomers = User.desc('okta.employeeStartDate').limit(15)
    render json: { count: User.count,
                   newcomers: newcomers.map { |n| UserSerializer.new(n) } }, status: :ok
  end

  def changes
    authorize! :read, :changes
    logs = Mongoid::AuditLog::Entry.desc(:created_at).limit(100)
    logs = logs.map do |l|
      { date: l.created_at,
        model: { name: l.document_path[0]['class_name'],
                 id: l.document_path[0]['id'].to_s },
        changes: l.tracked_changes }
    end
    render json: { count: Mongoid::AuditLog::Entry.count,
                   changes: logs }, status: :ok
  end
end
