Mau::Application.configure do

	# These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
	config.geokit.default_units = :miles
	config.geokit.default_formula = :sphere

	# This is the timeout value in seconds to be used for calls to the geocoder web
	# services.  For no timeout at all, comment out the setting.  The timeout unit
	# is in seconds.
	config.geokit.geocoders.request_timeout = 3

	# These settings are used if web service calls must be routed through a proxy.
	# These setting can be nil if not needed, otherwise, addr and port must be
	# filled in at a minimum.  If the proxy requires authentication, the username
	# and password can be provided as well.
	config.geokit.geocoders.proxy_addr = nil
	config.geokit.geocoders.proxy_port = nil
	config.geokit.geocoders.proxy_user = nil
	config.geokit.geocoders.proxy_pass = nil

	# This is your yahoo application key for the Yahoo Geocoder.
	# See http://developer.yahoo.com/faq/index.html#appid
	# and http://developer.yahoo.com/maps/rest/V1/geocode.html
	config.geokit.geocoders.yahoo = 'N.34cqHV34HBVzs_fNwThGrKQN8oMtEsizMOW14GriC2lceN7KrJKTklkpO2uUDX'

	# This is your Google Maps geocoder key.
	# See http://www.google.com/apis/maps/signup.html
	# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
	config.geokit.geocoders.google = Conf.ga_api_key

	# This is your username and password for geocoder.us.
	# To use the free service, the value can be set to nil or false.  For
	# usage tied to an account, the value should be set to username:password.
	# See http://geocoder.us
	# and http://geocoder.us/user/signup
	config.geokit.geocoders.geocoder_us = false

	# This is your authorization key for geocoder.ca.
	# To use the free service, the value can be set to nil or false.  For
	# usage tied to an account, set the value to the key obtained from
	# Geocoder.ca.
	# See http://geocoder.ca
	# and http://geocoder.ca/?register=1
	config.geokit.geocoders.geocoder_ca = false

	# Uncomment to use a username with the Geonames geocoder
	#config.geokit.geocoders.geonames="REPLACE_WITH_YOUR_GEONAMES_USERNAME"

	# This is the order in which the geocoders are called in a failover scenario
	# If you only want to use a single geocoder, put a single symbol in the array.
	# Valid symbols are :google, :yahoo, :us, and :ca.
	# Be aware that there are Terms of Use restrictions on how you can use the
	# various geocoders.  Make sure you read up on relevant Terms of Use for each
	# geocoder you are going to use.
	config.geokit.geocoders.provider_order = [:google,:yahoo]

	# The IP provider order. Valid symbols are :ip,:geo_plugin.
	# As before, make sure you read up on relevant Terms of Use for each
	# config.geokit.geocoders.ip_provider_order = [:geo_plugin,:ip]

end
