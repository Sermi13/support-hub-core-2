class Api::V1::Accounts::EvolutionController < Api::V1::Accounts::BaseController
  include Api::V1::InboxesHelper

  before_action :set_instance_name, only: [:show, :connect, :disconnect]

  def show
    response = evolution_api_client.fetch_instance(@instance_name)
    render_evolution_response(response)
  end

  def create
    ActiveRecord::Base.transaction do
      create_inbox_with_channel
      response = evolution_api_client.create_instance(evolution_payload)
      render_create_response(response)
    end
  rescue ActiveRecord::RecordInvalid => e
    log_error('CREATE', "Falha ao salvar inbox: #{e.message}")
    render json: { success: false, error: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue StandardError => e
    log_error('CREATE', "Erro inesperado: #{e.message}")
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def connect
    response = evolution_api_client.connect_instance(@instance_name)
    render_evolution_response(response)
  end

  def disconnect
    response = evolution_api_client.disconnect_instance(@instance_name)
    render_evolution_response(response)
  end

  private

  def set_instance_name
    @instance_name = params[:id] || params[:instance_name]
  end

  def permitted_params
    @permitted_params ||= params.permit(
      :instance_name, :ignore_groups, :always_online, :read_messages,
      :sign_message, :reopen_conversation, :import_contacts, :channel_name
    )
  end

  def evolution_api_client
    @evolution_api_client ||= EvolutionApiClient.new
  end

  def create_inbox_with_channel
    channel = create_channel
    @inbox = build_inbox(channel)
    attach_whatsapp_avatar
    @inbox.save!
  end

  def create_channel
    Current.account.api_channels.create!(
      webhook_url: webhook_url,
      integration_type: 'Evolution',
      integration_id: permitted_params[:instance_name]
    )
  end

  def build_inbox(channel)
    Current.account.inboxes.build(
      name: permitted_params[:channel_name],
      channel: channel
    )
  end

  def attach_whatsapp_avatar
    avatar_path = Rails.public_path.join('assets/images/dashboard/channels/whatsapp.png')
    return unless File.exist?(avatar_path)

    @inbox.avatar.attach(
      io: File.open(avatar_path),
      filename: 'whatsapp.png',
      content_type: 'image/png'
    )
  end

  def webhook_url
    "#{ENV.fetch('EVOLUTION_URL')}/chatwoot/webhook/#{permitted_params[:instance_name]}"
  end

  def evolution_payload
    {
      instanceName: permitted_params[:instance_name],
      qrcode: true,
      integration: 'WHATSAPP-BAILEYS',
      groupsIgnore: permitted_params[:ignore_groups],
      alwaysOnline: permitted_params[:always_online],
      readMessages: permitted_params[:read_messages],
      readStatus: true,
      syncFullHistory: false,
      chatwootAccountId: current_account.id.to_s,
      chatwootToken: current_user.access_token.token,
      chatwootUrl: ENV.fetch('FRONTEND_URL'),
      chatwootSignMsg: permitted_params[:sign_message],
      chatwootReopenConversation: permitted_params[:reopen_conversation],
      chatwootConversationPending: true,
      chatwootImportContacts: permitted_params[:import_contacts],
      chatwootNameInbox: permitted_params[:channel_name],
      chatwootMergeBrazilContacts: true,
      chatwootDaysLimitImportMessages: 10,
      chatwootOrganization: current_account.name
    }
  end

  def render_evolution_response(response)
    if response.success?
      render json: response.parsed_response, status: :ok
    else
      render json: { success: false, error: response.parsed_response }, status: response.code
    end
  end

  def render_create_response(response)
    if response.success?
      render json: {
        success: true,
        id: @inbox.id,
        evolution_response: JSON.parse(response.body)
      }, status: :ok
    else
      log_error('CREATE', "Erro ao criar instância: #{response.body}")
      render json: { success: false, error: response.parsed_response }, status: response.code
    end
  end

  def log_error(action, message)
    Rails.logger.error "[EVOLUTION][#{action}] #{message}"
  end
end

# Classe separada para lidar com API da Evolution
class EvolutionApiClient
  include HTTParty

  base_uri ENV.fetch('EVOLUTION_URL')

  def initialize
    @headers = { 'apikey' => ENV.fetch('EVOLUTION_TOKEN') }
  end

  def fetch_instance(instance_name)
    self.class.get(
      '/instance/fetchInstances',
      query: { instanceName: instance_name },
      headers: @headers
    )
  rescue StandardError => e
    Rails.logger.error "[EVOLUTION][SHOW] Unexpected error: #{e.message}"
    OpenStruct.new(success?: false, parsed_response: { error: e.message }, code: 500)
  end

  def create_instance(payload)
    self.class.post(
      '/instance/create',
      headers: @headers.merge('Content-Type' => 'application/json'),
      body: payload.to_json
    )
  end

  def connect_instance(instance_name)
    self.class.get("/instance/connect/#{instance_name}", headers: @headers)
  rescue StandardError => e
    Rails.logger.error "Erro ao conectar instância na Evolution: #{e.message}"
    OpenStruct.new(success?: false, parsed_response: { error: e.message }, code: 500)
  end

  def disconnect_instance(instance_name)
    self.class.delete("/instance/logout/#{instance_name}", headers: @headers)
  rescue StandardError => e
    Rails.logger.error "Erro ao desconectar instância na Evolution: #{e.message}"
    OpenStruct.new(success?: false, parsed_response: { error: e.message }, code: 500)
  end
end
