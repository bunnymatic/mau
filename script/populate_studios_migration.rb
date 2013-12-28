class PopulateStudios < ActiveRecord::Migration
  # add studios
  def self.add_studio(name, st, url, city="San Francisco", state="CA", zip="94117")
    if not Studio.find_by_name(name)
      st = Studio.new do |s|
        s.name = name
        s.street = st
        s.city = city
        s.state = state
        s.zip = zip
        s.url = url
      end
      st.save
      st.id
    else
      puts "Studio " + name + " has already been added"
    end
  end
  def self.up
    puts "Adding studios"
    # name, street, city, state, zip, url
    self.add_studio("1890 Bryant St Studios", "1890 Bryant St", "http://www.1890bryant.com")
    self.add_studio("ActivSpace","3150 18th Street, #102", "http://activspace.com")

    self.add_studio("The Blue Studio","2111 Mission St", "http://thebluestudio.org")
    self.add_studio("Developing Environments","540 Alabama St", "http://www.lightdark.com/deweb/index.html")
    self.add_studio("Project Artaud","499 Alabama Street", "http://artaud.org")
    self.add_studio("Workspace Limited","2150 Folsom St",  "http://workspacelimited.org")

  end

  def self.down
  end
end
