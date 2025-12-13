import gleeunit
import gleeunit/should
import gleam/io.{println}
import qcheck_gleeunit_utils/test_spec

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

pub fn part_2_ex_testx_()  {
  println("")
  println("")
  println("Running Dec 10 Part 2 Tests")
  test_spec.make(fn() {
    let l = dec_10.part2("./test/dec10/example.txt")
    should.equal(Ok(33), l)
  })
}

pub fn part_2_inp_testx_()  {
  println("")
  println("Input")
  test_spec.make(fn() {
    let l = dec_10.part2("./test/dec10/input.txt")
    should.equal(Ok(33), l)
  })
}

