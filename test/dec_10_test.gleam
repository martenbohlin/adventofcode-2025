import gleeunit
import gleam/io.{println}

import dec_10

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("Running Dec 10 Part 1 Tests")
  let l = dec_10.part1("./test/dec10/example.txt")
  assert Ok(7) == l

  println("")
  println("Input")
  let l = dec_10.part1("./test/dec10/input.txt")
  assert Ok(522) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 10 Part 2 Tests")
  let l = dec_10.part2("./test/dec10/example.txt")
  assert Ok(7) == l

  println("")
  println("Input")
  let l = dec_10.part2("./test/dec10/input.txt")
  assert Ok(258114870) == l
}

