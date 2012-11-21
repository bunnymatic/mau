module OsHelper
  def pretty_print_os_tag(os=nil)
    os ||= Conf.oslive.to_s
    yr = os[0..3]
    mo = os[4..-1]
    seas = (mo == '10') ? 'Oct':'Apr'
    "%s %s" % [ seas, yr ]
  end
end
    
