# frozen_string_literal: true
module MissionBoundaries
  # thanks, http://www.gps-coordinates.net/
  # order is important for the js overlay
  EAST_BOUNDARY = -122.40399999999999
  WEST_BOUNDARY = -122.430
  NORTH_BOUNDARY = 37.7751
  SOUTH_BOUNDARY = 37.747
  BOUNDS = {
    'NW' => [
      NORTH_BOUNDARY, WEST_BOUNDARY
    ],
    'SW' => [
      SOUTH_BOUNDARY, WEST_BOUNDARY
    ],
    'SE' => [
      SOUTH_BOUNDARY, EAST_BOUNDARY
    ],
    'NE' => [
      NORTH_BOUNDARY, EAST_BOUNDARY
    ]
  }.freeze

  def within_bounds?(lat, lng)
    return false unless lat && lng
    lat >= SOUTH_BOUNDARY && lat <= NORTH_BOUNDARY && lng >= WEST_BOUNDARY && lng <= EAST_BOUNDARY
  end
end
