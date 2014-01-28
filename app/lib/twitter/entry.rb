
module Twitter
  class Entry
    attr_accessor :description
    attr_accessor :date
    def title
      self.description
    end
  end
end
