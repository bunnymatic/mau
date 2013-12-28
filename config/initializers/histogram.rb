def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

