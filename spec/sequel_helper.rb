require 'spec_helper'

def test_database
  db = Sequel.sqlite
  Sequel.extension :migration
  Sequel::Migrator.run(db, File.join(__dir__,'migrations'))

  db
end
