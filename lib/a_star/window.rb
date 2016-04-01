module AStar
  class Window < Gtk::Window
    def initialize
      super
      self.set_size_request(580, 420)
      self.border_width = 10
      self.double_buffered = true
      self.realize
      self.signal_connect('destroy') do
        Gtk.main_quit
      end

      fixed = Gtk::Fixed.new
      @area = AStar::DrawingArea.new
      set_button_box
      fixed.put(@area, 0, 0)
      fixed.put(@button_box, 440, 20)
      self.add(fixed)

      @area.realize
      @area.drawable = @area.window
      @area.gc = Gdk::GC.new(@area.drawable)

      Gtk.timeout_add(100) do
        if @area.start_flag
          if @a_star.update == @a_star.goal
            @a_star.find_shortest_route
            @area.start_flag = false
            @area.end_flag = true
          end
        end
        @area.draw(@a_star)
        true
      end
    end

    private

    def set_button_box
      buttons = []
      buttons << button_start = Gtk::Button.new("START")
      buttons << button_stop = Gtk::Button.new("STOP")
      buttons << button_reset = Gtk::Button.new("RESET")

      # START
      button_start.signal_connect('clicked') do
        @area.start_flag = true
        @a_star ||= AStar.new(@area.a_star_options)
      end
      # STOP
      button_stop.signal_connect('clicked') do
        @area.start_flag = false
      end
      # RESET
      button_reset.signal_connect('clicked') do
        @a_star = nil
        @area.reset
      end

      buttons << button_10x10 = Gtk::RadioButton.new("10 x 10")
      buttons << button_20x20 = Gtk::RadioButton.new(button_10x10, "20 x 20", false)
      buttons << button_40x40 = Gtk::RadioButton.new(button_10x10, "40 x 40", false)

      # 10x10
      button_10x10.signal_connect('clicked') do
        if button_10x10.active?
          @a_star = nil
          @area.resize(10)
        end
      end

      # 20x20
      button_20x20.signal_connect('clicked') do
        if button_20x20.active?
          @a_star = nil
          @area.resize(20)
        end
      end

      # 40x40
      button_40x40.signal_connect('clicked') do
        if button_40x40.active?
          @a_star = nil
          @area.resize(40)
        end
      end

      @button_box = Gtk::VButtonBox.new
      @button_box.set_layout_style Gtk::ButtonBox::START
      @button_box.set_spacing 10
      buttons.each { |button| @button_box.add button }
    end
  end
end
