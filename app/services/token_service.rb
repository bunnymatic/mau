# frozen_string_literal: true
class TokenService
  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def self.generate
    self.secure_digest(Time.now, (1..10).map { rand.to_s })
  end
end
