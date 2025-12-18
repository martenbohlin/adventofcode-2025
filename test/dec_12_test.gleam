import gleeunit
import gleam/io.{println}
import qcheck_gleeunit_utils/test_spec
import gleeunit/should

import dec_12

pub fn main() {
  gleeunit.main()
}

pub fn part_1_testx() -> Nil {
  println("")
  println("Running Dec 12 Part 1 Tests")
  let l = dec_12.part1("./test/dec12/example.txt")
  assert Ok(2) == l

  println("")
  println("Input")
  let l = dec_12.part1("./test/dec12/input.txt")
  assert Ok(552) == l
}

pub fn part_2_testx() -> Nil {
  println("")
  println("")
  println("Running Dec 12 Pagirt 2 Tests")
  let l = dec_12.part2("./test/dec12/example2.txt")
  assert Ok(2) == l

  //println("")
  //println("Input")
  //let l = dec_12.part2("./test/dec12/input.txt")
  //assert Ok(307608674109300) == l
}

pub fn part_1_ex_testx_()  {
  test_spec.make(fn() {
    println("")
    println("")
    println("Running Dec 12 Part 1 Tests")
    let l = dec_12.part1("./test/dec12/example.txt")
    should.equal(Ok(2), l)
  })
}

pub fn part_1_inp_testx_()  {
  test_spec.make(fn() {
    println("")
    println("")
    println("Running Dec 12 Part 1 Tests Input")
    let l = dec_12.part1("./test/dec12/input.txt")
    should.equal(Ok(567), l)
  })
}


