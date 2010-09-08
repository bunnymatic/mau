class Medium < ActiveRecord::Base
  belongs_to :art_piece

  def self.frequency(normalize=false)
    # if normalize = true, scale counts from 1.0
    meds = []
    dbr = connection.execute("/* hand generated sql */  select medium_id medium, count(*) ct from art_pieces where medium_id <> 0 group by medium_id;")
    dbr.each_hash{ |row| meds << row }
    other = self.find(:all,:conditions => ["id not in (?)", meds.map { |m| m['medium'] } ])
    other.map { |m| meds << Hash["medium" => m.id, "ct" => 0 ] }
    # compute max/min ct
    maxct = nil
    meds.each do |m|
      if maxct == nil || maxct < m['ct'].to_i
        maxct = m['ct'].to_i
      end
    end  
    # normalize frequency to 1
    if maxct <= 0
      maxct = 1.0
    end
    if normalize
      meds.each do |m|
        m['ct'] = m['ct'].to_f / maxct.to_f
      end
    end
    meds
  end

  def safe_name
    self.name.gsub(' ', '&nbsp;')
  end

end
