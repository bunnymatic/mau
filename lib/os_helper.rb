module OsHelper
  def os_pretty(os = nil, reverse = false)
    ostag = (os || Conf.oslive.to_s)
    return 'n/a' unless ostag
    yr = ostag[0..3]
    mo = ostag[4..-1]
    seas = (mo == '10') ? 'Oct':'Apr'
    "%s %s" % (reverse ? [seas,yr] : [ yr, seas ])
  end
end
