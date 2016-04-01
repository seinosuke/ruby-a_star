require 'gtk2'

require "a_star/node"
require "a_star/algorithm"
require "a_star/window"
require "a_star/drawing_area"

module AStar
  def self.new(options)
    Algorithm.new(options)
  end
end
