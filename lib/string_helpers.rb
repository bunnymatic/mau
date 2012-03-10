# helpers for strings
module StringHelpers
  def self.trunc(msg, num_chars=100, ellipsis=true)
    # truncate string to num_chars
    # add ellipsis if ellipsis=true
    # num_chars includes ellipsis
    return nil unless msg && !msg.empty?
    num_chars = num_chars.to_i
    if msg.length < num_chars
      return msg
    end
    num_chars = num_chars - 1
    if ellipsis
      num_chars = num_chars - 3
    end
    if num_chars < 0
      return ""
    end
    msg = msg[0..num_chars]
    if ellipsis
      "%s..." % msg
    else
      msg
    end
  end    
  def trunc(msg, num_chars=100, ellipsis=true)
    StringHelpers.trunc msg, num_chars, ellipsis
  end   
end

  
