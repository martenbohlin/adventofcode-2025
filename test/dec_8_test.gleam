import gleeunit
import gleam/io.{println}

import dec_8

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("Running Dec 8 Part 1 Tests")
  let l = dec_8.part1("./test/dec8/example.txt", 10)
  assert Ok(40) == l

  println("")
  println("Input")
  let l = dec_8.part1("./test/dec8/input.txt", 1000)
  assert Ok(80446) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 8 Part 2 Tests")
  let l = dec_8.part2("./test/dec8/example.txt")
  assert Ok(25272) == l

  println("")
  println("Input")
  let l = dec_8.part2("./test/dec8/input.txt")
  assert Ok(51294528) == l
}

