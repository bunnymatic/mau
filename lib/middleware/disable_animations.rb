# frozen_string_literal: true

# Disable CSS animations for speed and consistency. This Rack middleware is
# only for test environments. It is added in config/environments/test.rb.

class DisableAnimations
  def initialize(app, _options = {})
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    return [status, headers, body] unless /html/ =~ (headers['Content-Type'] || '')

    response = Rack::Response.new([], status, headers)
    body.each { |fragment| response.write(inject_css_style_overrides(fragment)) }
    body.close if body.respond_to?(:close)
    response.finish
  end

  private

  def inject_css_style_overrides(fragment)
    disable_animations = <<~CSS
      <style>
        * {
           -o-transition-delay: 0s !important;
           -moz-transition-delay: 0s !important;
           -ms-transition-delay: 0s !important;
           -webkit-transition-delay: 0s !important;
           transition-delay: 0s !important;

           -o-transition-duration: 0s !important;
           -moz-transition-duration: 0s !important;
           -ms-transition-duration: 0s !important;
           -webkit-transition-duration: 0s !important;
           transition-duration: 0s !important;

           -o-animation-duration: 0s !important;
           -moz-animation-duration: 0s !important;
           -webkit-animation-duration: 0s !important;
           animation-duration: 0s !important;
         }
      </style>
    CSS
    fragment.gsub(%r{</head>}, disable_animations + '</head>')
  end
end
