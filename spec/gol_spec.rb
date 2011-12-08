# encoding: utf-8
$LOAD_PATH << File.expand_path(__FILE__)
$LOAD_PATH << File.join(File.expand_path(__FILE__),'spec')

require "./gol.rb"
require "rspec"

describe Board do
  let(:board) { Board.new(10,10) }
  
  context "prerequisites" do
    it "has defined dimension" do
      board.dimension.should == [10,10]
    end
    
    it "has a corresponding empty board matrix" do
      board.matrix.should == Matrix.zero(10,10)
    end
    
    it "gets a cell status" do
      board.cell(0,0).should == 0
      board[0,0].should == 0
    end
  end
  
  context "spawing cells" do
    it "can spawn a cell to a coord" do
      board.spawn_cell(3,3).should be_true
    end
    
    it "should not spawn a cell if already existing" do
      board.spawn_cell(3,3).should be_true
      board.spawn_cell(3,3).should be_false
    end
  end
  
  context "removing cells" do
    it "can remove a cell from coord" do
      board.spawn_cell(3,3)
      board.remove_cell(3,3).should be_true
    end
    
    it "should not remove a cell if already deleted or never existed" do
      board.remove_cell(3,3).should be_false
    end
  end
  
  context "neighbourhood" do
    it "returns neighbours count" do
      board.cell_neighbours(3,3).should == 0
      
      board.spawn_cell(2,3)
      board.cell_neighbours(3,3).should == 1
    end
  end
  
  context "ticking, states and processing" do
    it "has generation clock" do
      board.clock.should == 0
    end
    
    it "ticks and increments the clock" do
      board.tick!
      board.clock.should == 1
    end
    
    it "has a state/GC collector" do
      board.state_collector.should == {:deaths => [], :births => []}
    end
    
    context "- state processor" do
      it "returns false if nothing to do" do
        states = board.state_collector
        board.state_processor(states).should be_false
      end
      
      it "returns true if something to do" do
        board.spawn_cell(2,3)
        states = {:deaths => [[2,3]], :births => [[3,3]]}
        board.state_processor(states).should be_true
        board[3,3].should == 1
        board[2,3].should == 0
      end
    end
  end
  
  context "rules" do
    it "rule 1: Any live cell with fewer than two live neighbours dies, as if caused by under-population." do
      board.spawn_cell(3,3)
      
      board.spawn_cell(2,2)
      board.spawn_cell(1,1)
      
      states = board.state_collector
      states[:deaths].should include([3,3])
    end
    it "rule 2: Any live cell with two or three live neighbours lives on to the next generation." do
      board.spawn_cell(3,3)
      
      board.spawn_cell(2,2)
      board.spawn_cell(2,3)
      
      states = board.state_collector
      states[:deaths].should_not include([3,3])
      states[:births].should_not include([3,3])
    end
    it "rule 3: Any live cell with more than three live neighbours dies, as if by overcrowding." do
      board.spawn_cell(3,3)
      
      board.spawn_cell(2,2)
      board.spawn_cell(2,3)
      board.spawn_cell(2,4)
      board.spawn_cell(3,2)
      
      states = board.state_collector
      states[:deaths].should include([3,3])
    end
    it "rule 4: Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
      board.spawn_cell(3,2)
      board.spawn_cell(3,3)
      board.spawn_cell(3,4)
      
      states = board.state_collector
      states[:births].should include([2,3])
      states[:births].should include([4,3])
    end
  end
  
  it "changes states after a #tick! (oscillator test: blinker)" do
    board.spawn_cell(3,2)
    board.spawn_cell(3,3)
    board.spawn_cell(3,4)
    board.tick!    
    board[2,3].should == 1
    board[4,3].should == 1
    board[3,2].should == 0
    board[3,4].should == 0
    board.tick!    
    board[2,3].should == 0
    board[4,3].should == 0
    board[3,2].should == 1
    board[3,4].should == 1
    board.clock.should == 2
  end
  
  it "draws the board (ascii)" do
    result = <<EOS
..........
..........
..........
..........
..........
..........
..........
..........
..........
..........
EOS
    board.draw!('.','o').should == result
  end
  
end

