class TokenService
  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.join('--'))
  end

  def self.generate
    secure_digest(Time.new.to_i, Array.new(10) { rand.to_s })
  end
end
