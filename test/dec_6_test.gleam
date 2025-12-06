import gleeunit
import gleam/io.{println}

import dec_6

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 6 Part 1 Tests")
  let l = dec_6.part1("./test/dec6/example.txt")
  assert Ok(4277556) == l

  println("")
  println("Input")
  let l = dec_6.part1("./test/dec6/input.txt")
  assert Ok(7644505810277) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 6 Part 2 Tests")
  let l = dec_6.part2("./test/dec6/example.txt")
  assert Ok(3263827) == l

  println("")
  println("Input")
  let l = dec_6.part2("./test/dec6/input.txt")
  assert Ok(12841228084455) == l
}

