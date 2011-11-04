# encoding: utf-8
###
### http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
###

require "./init"

class Board
  attr_accessor :dx, :dy, :matrix, :clock
  
  def initialize x, y
    @dx, @dy = x, y
    @matrix = Matrix.zero(y,x)
    @clock = 0
  end
  
  def dimension
    [@dx,@dy]
  end
  
  def spawn_cell x, y
    if @matrix[y, x] == 0
      @matrix.send :[]=, y, x, 1
      true
    else
      false
    end
  end
  
  def remove_cell x, y
    if @matrix[y, x] != 0
      @matrix.send :[]=, y, x, 0
      true
    else
      false
    end
  end
  
  def cell_neighbours x, y
    range = -1..1
    ncount = 0
    range.each do |ny|
      next if y+ny < 0 || y+ny > @dy-1
      range.each do |nx|
        next if x+nx < 0 || x+nx > @dx-1 || [x,y] == [x+nx,y+ny]
        ncount += 1 if @matrix[y+ny,x+nx] > 0
      end
    end
    ncount
  end
  
  def state_collector
    dead_cells = []
    born_cells = []
    @matrix.each_with_index do |e,y,x|
      dead_cells << [x,y] if e == 1 && (self.cell_neighbours(x,y) < 2 || self.cell_neighbours(x,y) > 3)
      born_cells << [x,y] if e == 0 && self.cell_neighbours(x,y) == 3
    end
    {:deaths => dead_cells, :births => born_cells}
  end
  
  def state_processor states
    if !states[:deaths].empty? && !states[:births].empty?
      states[:deaths].each do |cell|
        @matrix.send :[]=, cell[1], cell[0], 0
      end
      states[:births].each do |cell|
        @matrix.send :[]=, cell[1], cell[0], 1
      end      
      true
    else
      false
    end
  end
  
  def tick!
    changes = state_collector
    changed = state_processor changes
    @clock += 1
    changed
  end
  
  def draw! no_cell=' ', a_cell='o'
    drawing = ""
    @matrix.each_with_index do |e,y,x|
      drawing << (e==0 ? no_cell : a_cell)
      drawing << "\n" if x+1 == @dx
    end
    drawing
  end
  
  def iterate! counts, no_cell=' ', a_cell='o', stepping = 3
    glyph = "━"
    puts "\e[H\e[2J" # clear screen!
    counts.times do
      break unless tick!
      
      out = ""
      puts "\e[H\e[2J"
      out << "┏"+glyph*(@dx)+"┓"
      out << "\n"
      draw!(no_cell,a_cell).split("\n").each do |line|
        out << "┃#{line}┃\n"
      end
      out << "┗"+glyph*(@dx)+"┛"
      puts "#{out}\n\n@@@ generation clock: #{clock}\n"
      sleep (1.0 / stepping)
    end
  end
end

