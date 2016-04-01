$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'a_star'

window = AStar::Window.new
window.show_all
Gtk.main
