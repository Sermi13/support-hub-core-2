class AddIntegrationFieldsToChannelApi < ActiveRecord::Migration[7.1]
  def change
    add_column :channel_api, :integration_type, :string
    add_column :channel_api, :integration_id, :string
  end
end
