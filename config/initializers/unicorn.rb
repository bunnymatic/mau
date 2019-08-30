<<<<<<< HEAD
# frozen_string_literal: true

if defined? Unicorn
  ::NewRelic::Agent.manual_start
  ::NewRelic::Agent.after_fork(force_reconnect: true)
=======
if defined? Unicorn
  ::NewRelic::Agent.manual_start()
  ::NewRelic::Agent.after_fork(:force_reconnect => true)
>>>>>>> parent of 302f5f47... move config files to puma
end
