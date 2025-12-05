import gleeunit
import gleam/io.{println}

import dec_5

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 5 Part 1 Tests")
  let l = dec_5.part1("./test/dec5/example.txt")
  assert Ok(3) == l

  println("")
  println("Input")
  let l = dec_5.part1("./test/dec5/input.txt")
  assert Ok(517) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 5 Part 2 Tests")
  let l = dec_5.part2("./test/dec5/example.txt")
  assert Ok(14) == l

  println("")
  println("Input")
  let l = dec_5.part2("./test/dec5/input.txt")
  assert Ok(336173027056994) == l
}

