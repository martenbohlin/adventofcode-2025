import gleeunit
import gleam/io.{println}

import dec_2

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 2 Part 1 Tests")
  let l = dec_2.part1("./test/dec2/example.txt")
  assert Ok(1227775554) == l

  let l = dec_2.part1("./test/dec2/input.txt")
  assert Ok(21139440284) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 2 Part 2 Tests")
  let l = dec_2.part2("./test/dec2/example.txt")
  assert Ok(4174379265) == l

  let l = dec_2.part2("./test/dec2/input.txt")
  assert Ok(38731915928) == l
}

