module AStar
  class Node
    attr_accessor :block, :current, :from, :move_cost

    def initialize(x, y, goal_x, goal_y)
      @current = [x, y]
      @from = []
      @block = false

      @move_cost = 0.0
      @heuristic_cost = Math.sqrt(
        (goal_x - @current[0]) ** 2 +
        (goal_y - @current[1]) ** 2
      )
    end

    def score
      @move_cost + @heuristic_cost
    end
  end
end
