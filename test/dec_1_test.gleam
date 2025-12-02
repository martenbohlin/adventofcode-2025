import gleeunit
import gleam/io.{println}

import dec_1

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 1 Part 1 Tests")
  let l = dec_1.part1("./test/dec1/example.txt")
  assert Ok(3) == l

  let l = dec_1.part1("./test/dec1/input.txt")
  assert Ok(989) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 1 Part 2 Tests")
  let l = dec_1.part2("./test/dec1/example.txt")
  assert Ok(6) == l

  let l = dec_1.part2("./test/dec1/input.txt")
  assert Ok(5941) == l
}
