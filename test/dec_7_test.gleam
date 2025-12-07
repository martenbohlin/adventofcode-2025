import gleeunit
import gleam/io.{println}

import dec_7

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 7 Part 1 Tests")
  let l = dec_7.part1("./test/dec7/example.txt")
  assert Ok(21) == l

  println("")
  println("Input")
  let l = dec_7.part1("./test/dec7/input.txt")
  assert Ok(1594) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 7 Part 2 Tests")
  let l = dec_7.part2("./test/dec7/example.txt")
  assert Ok(40) == l

  println("")
  println("Input")
  let l = dec_7.part2("./test/dec7/input.txt")
  assert Ok(15650261281478) == l
}

