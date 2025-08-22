class Conversations::PermissionFilterService
  attr_reader :conversations, :user, :account

  def initialize(conversations, user, account)
    @conversations = conversations
    @user = user
    @account = account
  end

  def perform
    return conversations if user_role == 'administrator'

    accessible_conversations
  end

  private

  # Returns the conversations that the user has access to
  # This includes:
  # - Conversations assigned to the user
  # - Conversations in the user's inboxes
  # - Conversations assigned to the user's teams

  def accessible_conversations
    user_assigned_ids = conversations.assigned_to(user).pluck(:id)

    user_inbox_ids = conversations.where(inbox: user.inboxes.where(account_id: account.id)).pluck(:id)

    user_team_ids = user.teams.pluck(:id)
    team_conversation_ids = conversations.where(team_id: user_team_ids).pluck(:id)

    all_conversation_ids = (user_assigned_ids + user_inbox_ids + team_conversation_ids).uniq

    conversations.where(id: all_conversation_ids)
  end

  def account_user
    AccountUser.find_by(account_id: account.id, user_id: user.id)
  end

  def user_role
    account_user&.role
  end
end

Conversations::PermissionFilterService.prepend_mod_with('Conversations::PermissionFilterService')
