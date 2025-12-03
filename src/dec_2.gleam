import simplifile
import gleam/string.{split,trim}
import gleam/int
//import gleam/io.{println}

fn to_ranges(list: List(String)) -> Result(List(#(Int, Int)), String) {
  case list {
    [] -> Ok([])
    [content, ..rest] -> case split(trim(content), "-") {
      [first, second] -> case int.parse(first), int.parse(second), to_ranges(rest) {
        Ok(first_int), Ok(second_int), Ok(tail)-> Ok([#(first_int, second_int), ..tail])
        _, _, _ -> Error("Failed to parse range (int)")
      }
      _ -> Error("Failed to parse range")
    }
  }
}

fn parse(filepath: String) -> Result(List(#(Int, Int)), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> to_ranges(split(trim(content), ","))
    Error(_) -> Error("Failed to read file")
  }
}

// For part1
//fn invalid(number: Int)-> Int {
//  let digits = int.to_string(number)
//  let length = string.length(digits)
//  let first = string.slice(digits, 0, length / 2)
//  let second = string.slice(digits, length / 2, length)
//  //println("Checking number: " <> digits <> " First: " <> first <> " Second: " <> second)
//  case first == second {
//    True -> number
//    False -> 0
//  }
//}

fn invalid(number: Int, repeat_length: Int)-> Int {
  let digits = int.to_string(number)
  let length = string.length(digits)
  case repeat_length <= length / 2 {
    False -> 0
    True -> {
      let first = string.slice(digits, 0, repeat_length)
      let repeated = string.repeat(first, length / repeat_length)
      case digits == repeated {
        True -> number
        False -> invalid(number, repeat_length + 1)
      }
    }
  }
}
fn check_range(start: Int, end: Int)-> Int {
  case start == end {
    True -> invalid(start, 1)
    False -> invalid(start, 1) + check_range(start + 1, end)
  }
}

fn find_invalid(data: List(#(Int, Int)))-> Result(Int, String) {
  case data {
    [] -> Ok(0)
    [#(start, end), ..rest] -> case find_invalid(rest) {
      Ok(invalid) -> Ok(invalid + check_range(start, end))
      Error(x) -> Error(x)
    }
  }
}


pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> find_invalid(data)
    Error(x) -> Error(x)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> find_invalid(data)
    Error(x) -> Error(x)
  }
}
