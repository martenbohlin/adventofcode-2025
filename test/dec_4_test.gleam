import gleeunit
import gleam/io.{println}

import dec_4

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 4 Part 1 Tests")
  let l = dec_4.part1("./test/dec4/example.txt")
  assert Ok(13) == l

  println("")
  println("Input")
  let l = dec_4.part1("./test/dec4/input.txt")
  assert Ok(1560) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 4 Part 2 Tests")
  let l = dec_4.part2("./test/dec4/example.txt")
  assert Ok(43) == l

  println("")
  println("Input")
  let l = dec_4.part2("./test/dec4/input.txt")
  assert Ok(9609) == l
}

