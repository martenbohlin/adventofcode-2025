import gleeunit
import gleam/io.{println}

import dec_11

pub fn main() {
  gleeunit.main()
}

pub fn part_1_test() -> Nil {
  println("")
  println("Running Dec 11 Part 1 Tests")
  let l = dec_11.part1("./test/dec11/example.txt")
  assert Ok(5) == l

  println("")
  println("Input")
  let l = dec_11.part1("./test/dec11/input.txt")
  assert Ok(552) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 11 Part 2 Tests")
  let l = dec_11.part2("./test/dec11/example.txt")
  assert Ok(7) == l

  println("")
  println("Input")
  let l = dec_11.part2("./test/dec11/input.txt")
  assert Ok(258114870) == l
}

