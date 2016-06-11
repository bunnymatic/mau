class ConvertAllTablesToUtf8 < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      get_non_utf_tables_sql = <<-EOSQL
        select t.table_name, ccsa.character_set_name
          from information_schema.`TABLES` t, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` ccsa
          where ccsa.collation_name = t.table_collation and
                ccsa.character_set_name <> 'utf8';
      EOSQL
      dbr = ActiveRecord::Base.connection.execute(get_non_utf_tables_sql)
      tables = dbr.map{|r| r[0]}
      tables.each do |table|
        convert_to_utf8_sql = "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8;"
        ActiveRecord::Base.connection.execute(convert_to_utf8_sql)
      end
    end
  end

  def down
  end
end
