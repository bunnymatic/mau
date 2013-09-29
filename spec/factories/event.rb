FactoryGirl.define do
  factory :event do
    title "Event Title"
    description "Desc"
    tweet "Tweeter"
    venue "over dere"
    street "121 main"
    city "sf"
    state "ca"
    zip "94117"
    starttime { Time.zone.now + 24.hours }
    endtime { Time.zone.now + 25.hours }
    reception_starttime { Time.zone.now + 24.hours }
    url 'http://cool.event.com'
  end
end
