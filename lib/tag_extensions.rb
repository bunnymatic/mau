class ActiveRecord::Base
  def tag_with tags
    tags.downcase.split(" ").each do |tag|
      Tag.find_or_create_by_name(tag).taggables << self
    end
  end

  def tag_list
    tags.map(&:name).join(' ')
  end

  def tag_delete tag_string
    split = tag_string.downcase.split(" ")
    tags.delete tags.select{|t| split.include? t.name}
  end
end
