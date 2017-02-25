# frozen_string_literal: true
class MediumPresenter < DelegatingPresenter
  def initialize(medium)
    super(medium)
    @medium = medium
  end

  def hashtag
    name = @medium.name
    name = name.split('-').map(&:strip).reverse.join('') if /^painting/i =~ name
    name.parameterize.underscore
  end
end
