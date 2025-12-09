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

pub fn part_2_test() -> Nil {
  println("")
  println("")
  println("Running Dec 9 Part 2 Tests")
  let l = dec_9.part2("./test/dec9/example.txt")
  assert Ok(25272) == l

  println("")
  println("Input")
  let l = dec_9.part2("./test/dec9/input.txt")
  assert Ok(51294529) == l
}

