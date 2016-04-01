module AStar
  class DrawingArea < Gtk::DrawingArea
    attr_accessor :drawable, :gc, :map_size, :start_flag, :end_flag

    def initialize
      super
      @width = 400
      @height = 400
      @map_size = 10
      @node_size = @width / @map_size
      @start_flag = false
      @end_flag = false
      @blocks = Array.new(@map_size) do
        Array.new(@map_size) { false }
      end

      self.set_size_request(@width+1, @height+1)
      self.set_app_paintable(true)
      self.set_events(
        Gdk::Event::BUTTON_MOTION_MASK |
        Gdk::Event::BUTTON_PRESS_MASK
      )
      self.signal_connect("expose_event") { clear; draw }
      self.signal_connect('motion_notify_event') { |_, evt| on_motion_notified(evt) }
      self.signal_connect('button_press_event') { |_, evt| on_button_pressed(evt) }
      alloc_color
    end

    def reset
      clear
      @start_flag = false
      @end_flag = false
      @blocks = Array.new(@map_size) do
        Array.new(@map_size) { false }
      end
    end

    def resize(size)
      clear
      @start_flag = false
      @end_flag = false
      @map_size = size
      @node_size = @width / @map_size
      @blocks = Array.new(@map_size) do
        Array.new(@map_size) { false }
      end
    end

    # Returns a hash used for the argument of `AStar.new`.
    def a_star_options
      blocks = []
      @map_size.times do |x|
        @map_size.times do |y|
          blocks << [x, y] if @blocks[x][y]
        end
      end
      {
        :x_size => @map_size,
        :y_size => @map_size,
        :start => [0, 0],
        :goal => [@map_size - 1, @map_size - 1],
        :blocks => blocks,
        :display => false,
      }
    end

    def clear
      @gc.set_foreground(@color_dict[:white])
      @drawable.draw_rectangle(@gc, true, 0, 0, @width, @height)
    end

    def draw(a_star = nil)
      draw_nodes(a_star) if a_star
      draw_node(0, 0, @color_dict[:red])
      draw_node(@map_size-1, @map_size-1, @color_dict[:blue])
      draw_grid
      draw_route(a_star) if @end_flag
    end

    private

    def draw_nodes(a_star)
      @map_size.times do |x|
        @map_size.times do |y|
          index = case true
          when @blocks[x][y]                    then :yellow
          when a_star.open_nodes[x][y].nil?.!   then :green
          when a_star.closed_nodes[x][y].nil?.! then :gray
          else nil
          end
          draw_node(x, y, @color_dict[index]) if index
        end
      end
    end

    def draw_node(x, y, color)
      x *= @node_size
      y *= @node_size
      @gc.set_foreground(color)
      @drawable.draw_rectangle(@gc, true, x, y, @node_size, @node_size)
    end

    def draw_route(a_star)
      @gc.set_foreground(@color_dict[:cyan])
      @gc.set_line_attributes(@node_size / 3.0, Gdk::GC::LINE_SOLID, Gdk::GC::CAP_ROUND, Gdk::GC::JOIN_BEVEL)
      from = [
        (@map_size-1)*@node_size + @node_size/2.0,
        (@map_size-1)*@node_size + @node_size/2.0
      ]
      (a_star.result + [[0, 0]]).each do |x, y|
        to = [
          x*@node_size + @node_size/2.0,
          y*@node_size + @node_size/2.0
        ]
        @drawable.draw_line(@gc, *from, *to)
        from = to
      end
    end

    def draw_grid
      @gc.set_foreground(@color_dict[:black])
      @gc.set_line_attributes(1, Gdk::GC::LINE_SOLID, Gdk::GC::CAP_ROUND, Gdk::GC::JOIN_BEVEL)

      (0..@map_size).each_with_object(@node_size).map(&:*).each do |x|
        @drawable.draw_line(@gc, x, 0, x, @height)
      end
      (0..@map_size).each_with_object(@node_size).map(&:*).each do |y|
        @drawable.draw_line(@gc, 0, y, @width, y)
      end
    end

    def alloc_color
      @color_dict = {
        :red => Gdk::Color.new(65535, 0, 0),
        :green => Gdk::Color.new(0, 65535, 0),
        :blue => Gdk::Color.new(0, 0, 65535),
        :cyan => Gdk::Color.new(0, 65535, 65535),
        :yellow => Gdk::Color.new(65535, 65535, 0),
        :black => Gdk::Color.new(0, 0, 0),
        :gray => Gdk::Color.new(50000, 50000, 50000),
        :white => Gdk::Color.new(65535, 65535, 65535),
      }
      colormap = Gdk::Colormap.system
      @color_dict.each do |_, color|
        colormap.alloc_color(color, false, true)
      end
    end

    def on_motion_notified(event)
      unless @start_flag
        x = event.x.to_i / @node_size
        y = event.y.to_i / @node_size
        if x.between?(0, @map_size-1) && y.between?(0, @map_size-1)
          draw_node(x, y, @color_dict[:yellow])
          @blocks[x][y] = true
        end
      end
    end

    def on_button_pressed(event)
      unless @start_flag
        x = event.x.to_i / @node_size
        y = event.y.to_i / @node_size
        if x.between?(0, @map_size-1) && y.between?(0, @map_size-1)
          if @blocks[x][y]
            draw_node(x, y, @color_dict[:white])
            @blocks[x][y] = false
          else
            draw_node(x, y, @color_dict[:yellow])
            @blocks[x][y] = true
          end
        end
      end
    end
  end
end
