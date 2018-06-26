require 'sinatra/base'

module Sinatra
  module TooltipHelpers
    

    def tooltip(text, tooltip)
      "&nbsp;<span data-balloon=\"#{tooltip}\" data-balloon-pos=\"up\"><u>#{text}</u></span>&nbsp;"
    end

    def render_tooltip(text, tooltip_pair)
      tooltip_pair.each do |key, value|
        text.gsub! key, tooltip(text[key], value)
      end
      text
    end
  end
  helpers TooltipHelpers
end
