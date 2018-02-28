# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :aa_network do
      primary_key :uniqueIdentifier
      column :organizationName, String, size: 128, null: false,
      column :manager, Integer,
      column :lastModifiedTime, Timestamp,
      column :lastModifiedBy, String, size: 64, null: false,
      column :dlpsDeleted, String, size: 1, null: false
    end
  end
end
