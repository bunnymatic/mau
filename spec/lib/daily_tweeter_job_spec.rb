require File.dirname(__FILE__) + "/../spec_helper"

describe DailyTweeterJob do
  context 'job' do
    before do
      DailyTweeterJob.any_instance.stubs(:tweet)
    end
    it "gets enqueued DelayedJob" do
      pending "not ready for primetime"
      Delayed::Job.expects(:enqueue).once.with() do |job, priority, time|
        job.class.should == DailyTweeterJob
      end
      DailyTweeterJob.new.perform
    end
    
    it 'enqueues the DelayedJob at least 1 days hence' do
      pending "not ready for primetime"
      Delayed::Job.expects(:enqueue).once.with() do |job, priority, time|
        time.should be_close 1.days.since, 20.minutes
      end
      DailyTweeterJob.new.perform
    end
  end
end

describe 'tweet reminder' do
  it 'authenticates our twitter user' do
    pending "not ready for primetime"
    auth = { :type => :oauth,
      :consumer_key => 'V7Nif8IiVQnajQ3XUslwcg',
      :consumer_secret => 'UUvDXjUu6SK8DxrqwNNSYrcROYP0osMJmPUSOpxZ0',
      :token => '62131363-mPnEym1H3rBeA0wKnqNRAPMpSBr6UZOdLpUM7yx0W',
      :token_secret => 'XSDpwrfxRya6KHB3azNrtBKxG0hAjxJKJc8JGFRQhxQ' 
    }
    m = stub(:statuses => stub( :update! => 'go' ))
    Grackle::Client.expects(:new).once.with(:auth => cfg).returns(m)
    DailyTweeterJob.new.send(:tweet, stub(:pithy_message =>'give me pith or give me death'))
  end
  it 'tweets a message' do
    pending "not ready for primetime"
    m = mock "GrackleClient"
    Grackle::Client.any_instance.expects(:statuses).once.returns(m)
    m.expects(:update!).once
    DailyTweeterJob.new.send(:tweet, stub(:pithy_message =>'give me pith or give me death'))
  end
end

describe 'perform' do
  it 'looks up today\'s message by date' do
    pending "not ready for primetime"
    DailyTweeterJob.any_instance.stubs(:tweet)
    time = Time.parse("Wed Jan 05 17:37:23 -0800 2011")
    Time.stubs(:now).returns(time)
    ReminderPlan.expects(:find_by_deliver_on).once.with(time.to_date)
    DailyTweeterJob.new.perform
  end
  it 'tweet reminder is called' do
    pending "not ready for primetime"
    reminder = stub(:pithy_message => 'something')
    ReminderPlan.expects(:find_by_deliver_on).returns(reminder)
    DailyTweeterJob.any_instance.expects(:tweet).once.with(reminder)
    DailyTweeterJob.new.perform
  end
  it "doesn't tweet if the reminder's pithy message is empty" do
    pending "not ready for primetime"
    reminder = stub(:pithy_message => '')
    ReminderPlan.expects(:find_by_deliver_on).returns(reminder)
    DailyTweeterJob.any_instance.expects(:tweet).never
    DailyTweeterJob.new.perform
  end
end
