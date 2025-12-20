import gleeunit
import gleam/io.{println}

import dec_9

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("Running Dec 9 Part 1 Tests")
  let l = dec_9.part1("./test/dec9/example.txt")
  assert Ok(50) == l

  println("")
  println("Input")
  let l = dec_9.part1("./test/dec9/input.txt")
  assert Ok(4754955192) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 9 Part 2 Tests")
  let l = dec_9.part2("./test/dec9/example.txt")
  assert Ok(24) == l

  println("")
  println("Input")
  let l = dec_9.part2("./test/dec9/input.txt")
  assert Ok(1568849600) == l
  // Too low 258114870
}

pub fn intersects_testx() -> Nil {
  // Parallel overlapping
  let x = dec_9.intersects(
    #(#(0,0), #(0,10)),
    #(#(0,5), #(0, 15))
  )
  assert False == x

  // True intersects
  let x = dec_9.intersects(
  #(#(2,0), #(2,10)),
  #(#(0,5), #(3, 5))
  )
  assert True == x

  // crossing but not overlapping
  let x = dec_9.intersects(
  #(#(2,0), #(2,10)),
  #(#(3,5), #(5, 5))
  )
  assert False == x

  // crossing but starting on line going out
  let x = dec_9.intersects(
  #(#(2,0), #(2,10)),
  #(#(2,5), #(5, 5))
  )
  assert False == x

  // crossing but starting on line going in
  let x = dec_9.intersects(
  #(#(2,0), #(2,10)),
  #(#(1,5), #(2, 5))
  )
  assert True == x
}
