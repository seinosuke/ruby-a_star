$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'a_star'

blocks = [
  [10, 20], [11, 20], [12, 20], [13, 20], [14, 20], [15, 20],
  [16, 20], [17, 20], [18, 20], [19, 20], [20, 20],
  [21, 20], [22, 20], [23, 20], [24, 20], [25, 20],
  [25, 19], [25, 18], [25, 17],
]

options = {
  :x_size => 30,
  :y_size => 30,
  :start => [10, 9],
  :goal => [25, 28],
  :blocks => blocks,
  :display => true
}

a_star = AStar.new(options)
a_star.exec
