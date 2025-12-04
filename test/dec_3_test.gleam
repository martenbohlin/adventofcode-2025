import gleeunit
import gleam/io.{println}

import dec_3

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 3 Part 1 Tests")
  let l = dec_3.part1("./test/dec3/example.txt")
  assert Ok(357) == l

  println("")
  println("Input")
  let l = dec_3.part1("./test/dec3/input.txt")
  assert Ok(17158) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 3 Part 2 Tests")
  let l = dec_3.part2("./test/dec3/example.txt")
  assert Ok(3121910778619) == l

  println("")
  println("Input")
  let l = dec_3.part2("./test/dec3/input.txt")
  assert Ok(170449335646486) == l
}

