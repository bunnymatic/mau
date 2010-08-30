require 'test_helper'

class TagTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :tags
  test "add delete tag" do
    t = tags(:one)
    _id = t.id
    t.save()
    tt = Tag.find(_id)
    assert_equal(tt.name, t.name)
    tt.delete()
    caught = false
    begin
      ttt = Tag.find(_id)
    rescue ActiveRecord::RecordNotFound
      caught = true
    end
    assert(caught)
  end

  test "safe name" do
    t = tags(:with_spaces)
    assert( t.safe_name.include?('&nbsp;') )
  end
  # TODO: this should really fail - don't allow tags that are only whitespace
  # requires model update
  test "add empty tag" do
    t = tags(:empty)
    _id = t.id
    t.save()
  end
end
