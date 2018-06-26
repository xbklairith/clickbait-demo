require 'sinatra/base'

module Sinatra
  module AirportHelpers
    def show_place place 
      place.dig('province') || place.dig('city') || place.dig('country') || place.dig('airport_name') if place
    end

    def type_place place
      if place.dig('province')
        'City'
      elsif place.dig('city')
        'City'
      elsif place.dig('country')
        'Country'
      elsif place.dig('airport_name')
        'Port'
      end
    end




  end
  helpers AirportHelpers
end