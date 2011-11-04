#!/usr/bin/env ruby
# encoding: utf-8
require "./gol"

board = Board.new 120,50

offx,offy = 54,24
# an infinite pattern (5x5)
[
  [offx+1,offy+1],[offx+2,offy+1],[offx+3,offy+1],[offx+5,offy+1],
  [offx+1,offy+2],
  [offx+4,offy+3],[offx+5,offy+3],
  [offx+2,offy+4],[offx+3,offy+4],[offx+5,offy+4],
  [offx+1,offy+5],[offx+3,offy+5],[offx+5,offy+5]
].each do |e|
  board.spawn_cell e[0],e[1]
end

                         # ✺ ☻ ⬣ ● ⨀
board.iterate! 2500, ' ','⬤', 12

