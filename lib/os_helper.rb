module OsHelper
  def os_pretty(os = nil)
    ostag = (os || Conf.oslive.to_s)
    return 'n/a' unless ostag
    yr = ostag[0..3]
    mo = ostag[4..-1]
    seas = (mo == '10') ? 'Oct':'Apr'
    "%s %s" % [ yr, seas ]
  end
end
