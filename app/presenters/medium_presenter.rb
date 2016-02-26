class MediumPresenter < DelegatingPresenter

  def initialize(medium)
    super(medium)
    @medium = medium
  end

  def hashtag
    name = @medium.name
    if /^painting/i =~ name
      name = name.split("-").map(&:strip).reverse.join("")
    end
    hashtag = name.parameterize.underscore
  end

end
