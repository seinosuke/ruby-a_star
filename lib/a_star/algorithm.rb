module AStar
  class Algorithm
    attr_reader :nodes, :open_nodes, :closed_nodes, :shortest_route, :goal, :result

    def initialize(options = {})
      options.each { |key ,val| eval "@#{key} = #{val}" }

      reset_nodes
      set_blocks(@blocks)

      @open_nodes[@start[0]][@start[1]] = AStar::Node.new(*@start, *@goal)
      @open_nodes[@start[0]][@start[1]].from = [0, 0]
    end

    # Reset nodes, open nodes and closed nodes to default state.
    def reset_nodes
      @result = []
      @shortest_route = Array.new(@x_size).map{ Array.new(@y_size, false) }
      @nodes = Array.new(@x_size).map{ Array.new(@y_size, nil) }
      @open_nodes = Array.new(@x_size).map{ Array.new(@y_size, nil) }
      @closed_nodes = Array.new(@x_size).map{ Array.new(@y_size, nil) }

      @x_size.times do |x|
        @y_size.times do |y|
          @nodes[x][y] = AStar::Node.new(x, y, *@goal)
        end
      end
    end

    def set_blocks(blocks)
      blocks.each do |x, y|
        @nodes[x][y].block = true
      end
    end

    # Start searching by using the A* algorithm.
    def exec
      print "\e[?25l"

      loop do
        if @display
          puts self
          print "\e[#{@y_size + 1}A"; STDOUT.flush; #sleep 0.1
        end
        break if self.update == @goal
      end

      find_shortest_route
      puts self if @display
      print "\e[?25h"
    rescue Interrupt
      print "\e[?25h"
      exit 1
    end

    # Search a position of the node that has the minimun score from the open nodes
    # and open the tartget node.
    def update
      target_pos = 
        @open_nodes.flatten.select { |node| !node.nil? }
        .min_by { |node| node.score }.current
      open_node(*target_pos)
      target_pos
    end

    # Get the shortest route from the closed list.
    def find_shortest_route
      node = @closed_nodes[@goal[0]][@goal[1]]
      loop do
        break if node.from == @start
        @result << node.from
        @shortest_route[node.from[0]][node.from[1]] = true
        node = @closed_nodes[node.from[0]][node.from[1]]
      end
    end

    # Open a node at (x, y).
    def open_node(x, y)
      [*-1..1].repeated_permutation(2).to_a
      .reject { |dxdy| dxdy == [0, 0] }.each do |dx, dy|
      # .reject { |dx, dy| dx*dy != 0 }.each do |dx, dy| # prohibit a move in the oblique direction

        next if ( x+dx == -1 || x+dx == @x_size || y+dy == -1 || y+dy == @y_size )
        next if @nodes[x+dx][y+dy].block

        move_cost = dx*dy == 0 ? 1 : Math.sqrt(2)
        @nodes[x+dx][y+dy].move_cost = @open_nodes[x][y].move_cost + move_cost
        @nodes[x+dx][y+dy].from = [x, y]
        check_unique(x+dx, y+dy)
      end

      # Move the node at (x, y) from the open list to the closed list.
      @closed_nodes[x][y] = Marshal.load(Marshal.dump(@open_nodes[x][y]))
      @open_nodes[x][y] = nil
    end

    # Check whether or not the node at (x, y) is a new node.
    def check_unique(x, y)

      # If a node at (x, y) exists in the open list, 
      # and a score of the new node is lower than the its score,
      # add the new node to the open list.
      if @open_nodes[x][y]
        if @open_nodes[x][y].score > @nodes[x][y].score
          @open_nodes[x][y].move_cost = @nodes[x][y].move_cost
          @open_nodes[x][y].from = Marshal.load(Marshal.dump(@nodes[x][y].from))
        end
        return
      end

      # If a node at (x, y) exists in the closed list, 
      # and a score of the new node is lower than the its score,
      # add the new node to the open list and remove from the closed list.
      if @closed_nodes[x][y]
        if @closed_nodes[x][y].score > @nodes[x][y].score
          @closed_nodes[x][y] = nil
          @open_nodes[x][y] = AStar::Node.new(x, y, *@goal)

          @open_nodes[x][y].move_cost = @nodes[x][y].move_cost
          @open_nodes[x][y].from = Marshal.load(Marshal.dump(@nodes[x][y].from))
        end
        return
      end

      # If a node at (x, y) exists in the open list and closed list,
      # add to the open list.
      @open_nodes[x][y] = AStar::Node.new(x, y, *@goal)
      @open_nodes[x][y].move_cost = @nodes[x][y].move_cost
      @open_nodes[x][y].from = Marshal.load(Marshal.dump(@nodes[x][y].from))
    end

    def to_s
      "\n  " << @y_size.times.map do |y|
        @x_size.times.map do |x|
          case true
          when @start == [x, y]
            "\e[41m  \e[0m" # start (red)
          when @goal == [x, y]
            "\e[44m  \e[0m" # goal (blue)
          when @nodes[x][y].block
            "\e[43m  \e[0m" # block (yellow)
          when @shortest_route[x][y]
            "\e[46m  \e[0m" # route (cyan)
          when @open_nodes[x][y].nil?.!
            "\e[42m  \e[0m" # open node (green)
          when @closed_nodes[x][y].nil?.!
            "\e[100m  \e[0m" # closed node (gray)
          else
            "\e[47m  \e[0m" # nomal node (white)
          end
        end.join("")
      end.join("\n  ")
    end
  end
end
