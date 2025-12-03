import simplifile
import gleam/string.{split,trim}
import gleam/int
//import gleam/io.{println}
import gleam/list.{length}

fn to_ints(strings: List(String)) -> Result(List(Int), String) {
  case strings {
    [] -> Ok([])
    [first, ..rest] -> case int.parse(first) {
      Ok(n) -> case to_ints(rest) {
        Ok(tail) -> Ok([n, ..tail])
        Error(x) -> Error(x)
      }
      Error(_) -> Error("Failed to parse int")
    }
  }
}

fn parse_line(line: String) -> Result(List(Int), String) {
  to_ints(string.split(line, ""))
}

fn parse_lines(lines: List(String)) -> Result(List(List(Int)), String) {
  case lines {
    [] -> Ok([])
    [first, ..rest] -> case parse_line(first), parse_lines(rest) {
      Ok(parsed_first), Ok(parsed_rest) -> Ok([parsed_first, ..parsed_rest])
      _, Error(x) -> Error(x)
      Error(x), _ -> Error(x)
    }
  }
}

fn parse(filepath: String) -> Result(List(List(Int)), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> parse_lines(split(trim(content), "\n"))
    Error(_) -> Error("Failed to read file")
  }
}

fn solve_p1_line_d2(data: List(Int)) -> Int {
  case data {
    [] -> -999999
    [this, ..rest] -> {
      let other = solve_p1_line_d2(rest)
      case this >= other {
        True -> this
        False -> other
      }
    }
  }
}

fn solve_p1_line(data: List(Int)) -> #(Int, List(Int)) {
  case data {
    [] -> #(-999999, [])
    [_last] -> #(0, []) // Need one more to use as second digit
    [this, ..rest] -> {
      let #(other, other_rest) = solve_p1_line(rest)
      case this >= other {
        True -> #(this, rest)
        False -> #(other, other_rest)
      }
    }
  }
}

fn solve_p1(data: List(List(Int))) -> Result(Int, String) {
  case data {
    [] -> Ok(0)
    [first, ..rest] -> case solve_p1_line(first), solve_p1(rest) {
      #(line_result, rest), Ok(aggregate) -> {
        let l = line_result * 10 + solve_p1_line_d2(rest)
        //println("Line Result: " <> int.to_string(l) <> " Aggregate: " <> int.to_string(aggregate))
        Ok(l + aggregate)
      }
      _, Error(x) -> Error(x)
    }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data)
    Error(x) -> Error(x)
  }
}

fn solve_p2_line_d(data: List(Int), numbers: Int) -> #(Int, List(Int)) {
  case length(data) >= numbers, data {
    True, [head, ..tail] -> {
      let #(other, other_tail) = solve_p2_line_d(tail, numbers)
      case head >= other {
        True -> #(head, tail)
        False -> #(other, other_tail)
      }
    }
    _, _ -> #(0, [])
  }
}

fn solve_p2_line(data: List(Int), numbers: Int, aggregate: Int) -> Int {
  case numbers {
    0 -> aggregate
    _ -> {
      let #(x, rest) = solve_p2_line_d(data, numbers)
      solve_p2_line(rest, numbers - 1, aggregate * 10 + x)
    }
  }
}

fn solve_p2(data: List(List(Int))) -> Int {
  case data {
    [] -> 0
    [first, ..rest] -> case solve_p2_line(first, 12, 0), solve_p2(rest) {
      line_result, aggregate -> {
        //println("Line Result: " <> int.to_string(line_result) <> " Aggregate: " <> int.to_string(aggregate))
        line_result + aggregate
      }
    }
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> Ok(solve_p2(data))
    Error(x) -> Error(x)
  }
}
