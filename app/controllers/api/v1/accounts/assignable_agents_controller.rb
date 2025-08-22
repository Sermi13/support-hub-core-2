class Api::V1::Accounts::AssignableAgentsController < Api::V1::Accounts::BaseController
  before_action :fetch_inboxes

  def index
    ## Removed old original chatwoot logic
    # agent_ids = @inboxes.map do |inbox|
    #   authorize inbox, :show?
    #   member_ids = inbox.members.pluck(:user_id)
    #   member_ids
    # end
    # agent_ids = agent_ids.inject(:&)
    # agents = Current.account.users.where(id: agent_ids)
    # @assignable_agents = (agents + Current.account.administrators).uniq

    @assignable_agents = Current.account.users.order_by_full_name.includes(:account_users, { avatar_attachment: [:blob] })
  end

  private

  def fetch_inboxes
    @inboxes = Current.account.inboxes.find(permitted_params[:inbox_ids])
  end

  def permitted_params
    params.permit(inbox_ids: [])
  end
end
