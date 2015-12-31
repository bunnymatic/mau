class ActiveRecord::Base
  # if Rails::VERSION::MAJOR <= 3
  #   def write_attributes(attrs = nil)
  #     if attrs.present?
  #       attrs.each do |attr, value|
  #         attr_setter = "#{attr}="
  #         self.send(attr_setter, value)
  #       end
  #     end
  #   end
  # end

  def self.find_random(num = 1, opts = {})
    # skip out if we don't have any
    return nil if (max = self.count(opts)) == 0

    # don't request more than we have
    num = [max,num].min

    # build up a set of random offsets to go find
    find_ids = [] # this is here for scoping

    # get rid of the trivial cases
    if 1 == num # we only want one - pick one at random
      find_ids = [rand(max)]
    else
      # just randomise the set of possible ids
      find_ids = (0..max-1).to_a.sort_by { rand }
      # then grab out the number that we need
      find_ids = find_ids.slice(0..num-1) if num != max
    end

    # we've got a random set of ids - now go pull out the records
    find_ids.map {|the_id| first(opts.merge(:offset => the_id)) }
  end
end
