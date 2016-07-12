class ChangeMauFanToMauFan < ActiveRecord::Migration
  def up
    sql = "update users set type='MauFan' where type='MAUFan'"
    ActiveRecord::Base.connection.execute(sql)
  end
  def down
    sql = "update users set type='MAUFan' where type='MauFan'"
    ActiveRecord::Base.connection.execute(sql)
  end
end
