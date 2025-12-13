import gleeunit
import gleam/io.{println}

import dec_11

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("Running Dec 11 Part 1 Tests")
  let l = dec_11.part1("./test/dec11/example.txt")
  assert Ok(5) == l

  println("")
  println("Input")
  let l = dec_11.part1("./test/dec11/input.txt")
  assert Ok(552) == l
}

pub fn part_2_test() -> Nil {
  println("")
  println("")
  println("Running Dec 11 Pagirt 2 Tests")
  let l = dec_11.part2("./test/dec11/example2.txt")
  assert Ok(2) == l

  println("")
  println("Input")
  let l = dec_11.part2("./test/dec11/input.txt")
  assert Ok(307608674109300) == l
}

