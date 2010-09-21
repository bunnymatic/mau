require 'test_helper'


class StudioTest < ActiveSupport::TestCase

  fixtures :studios

  test "Find studio in Studios.all" do
    sts = Studio.all
    studio_fixture = studios(:s1890)
    found = {:s1890 => false,
      :blue => false,
      :as => false}
    sts.each do |s|
      if s.name == studio_fixture.name
        assert_equal(s.name, studio_fixture.name)
        assert_equal(s.street, studio_fixture.street)
        assert_equal(s.city, studio_fixture.city)
        assert_equal(s.state, studio_fixture.state)
        assert_equal(s.zip, studio_fixture.zip)
        found[:s1890] = true
      end
    end

    studio_fixture = studios(:blue)
    sts.each do |s|
      if s.name == studio_fixture.name
        assert_equal(s.name, studio_fixture.name)
        assert_equal(s.street, studio_fixture.street)
        assert_equal(s.city, studio_fixture.city)
        assert_equal(s.state, studio_fixture.state)
        assert_equal(s.zip, studio_fixture.zip)
        found[:blue] = true
      end
    end

    studio_fixture = studios(:as)
    sts.each do |s|
      if s.name == studio_fixture.name
        assert_equal(s.name, studio_fixture.name)
        assert_equal(s.street, studio_fixture.street)
        assert_equal(s.city, studio_fixture.city)
        assert_equal(s.state, studio_fixture.state)
        assert_equal(s.zip, studio_fixture.zip)
        found[:as] = true
      end
    end

    assert(found[:s1890])
    assert(found[:blue])
    assert(found[:as])
  end


  test "Find studio Studio.find" do
    sts = Studio.find(:all, :conditions => ['name like "%%1890%%"'])
    studio_fixture = studios(:s1890)
    found = {:s1890 => false,
      :as => false,
      :blue => false}
    sts.each do |s|
      if s.name == studio_fixture.name
        assert_equal(s.name, studio_fixture.name)
        assert_equal(s.street, studio_fixture.street)
        assert_equal(s.city, studio_fixture.city)
        assert_equal(s.state, studio_fixture.state)
        assert_equal(s.zip, studio_fixture.zip)
        found[:s1890] = true
      end
    end
    sts = Studio.find(:all, :conditions => ['name like "%%blue%%"'])
    studio_fixture = studios(:blue)
    sts.each do |s|
      if s.name == studio_fixture.name
        assert_equal(s.name, studio_fixture.name)
        assert_equal(s.street, studio_fixture.street)
        assert_equal(s.city, studio_fixture.city)
        assert_equal(s.state, studio_fixture.state)
        assert_equal(s.zip, studio_fixture.zip)
        found[:blue] = true
      end
    end
    assert(found[:s1890])
    assert(found[:blue])
    assert(!found[:as])
  end

end
