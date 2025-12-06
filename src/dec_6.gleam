import simplifile
import gleam/string.{split,trim}
import gleam/int
import gleam/list

fn parse_line(line: String) -> List(Int) {
  case line {
    "" -> []
    _ -> {
      case string.split_once(line, " ") {
        Ok(#(x, rest_of_line)) -> {
          case int.parse(x) {
            Ok(n) -> [n, ..parse_line(string.trim(rest_of_line))]
            Error(_) -> []
          }
        }
        Error(_) -> case int.parse(line) {
          Ok(n) -> [n]
          Error(_) -> []
        }
      }
    }
  }
}

fn parse_type(line: String) -> List(String) {
  case line {
    "" -> []
    _ -> {
      case string.split_once(line, " ") {
        Ok(#(x, rest_of_line)) -> [x, ..parse_type(string.trim(rest_of_line))]
        Error(_) -> [line]
      }
    }
  }
}

fn parse_lines(lines: List(String), result: List(List(Int))) -> #(List(String),List(List(Int))) {
  case lines {
    [] -> #([], result)
    [last_row] -> #(parse_type(string.trim(last_row)), result)
    [first, ..rest] -> {
      parse_lines(rest, [parse_line(string.trim(first)), ..result])
    }
  }
}

fn parse(filepath: String) -> Result(#(List(String),List(List(Int))), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> {
      let #(types, numbers) = parse_lines(split(trim(content), "\n"), [])
        Ok(#(types, list.transpose(numbers))) // Flip array to get list of columns instead of list of rows
    }
    Error(_) -> Error("Failed to read file")
  }
}

fn sum(numbers: List(Int)) -> Int {
  case numbers {
    [] -> 0
    [first, ..rest] -> first + sum(rest)
  }
}

fn product(numbers: List(Int)) -> Int {
  case numbers {
    [] -> 1
    [first, ..rest] -> first * product(rest)
  }
}

fn solve_p1(types: List(String), numbers: List(List(Int)), aggregate: Int) -> Int {
  case types, numbers {
    [], [] -> aggregate
    [first_type, ..rest_types], [first_numbers, ..rest_numbers] -> {
      case first_type {
        "+" -> {
          let x = sum(first_numbers)
          echo x
          solve_p1(rest_types, rest_numbers, aggregate + x)
        }
        "*" -> {
          let x = product(first_numbers)
          echo x
          solve_p1(rest_types, rest_numbers, aggregate + x)
        }
        _ -> aggregate
      }
    }
    _, _ -> aggregate
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(#(types, numbers)) -> {
      Ok(solve_p1(types, numbers,0))
    }
    Error(x) -> Error(x)
  }
}

////////////////////////////////
// Part 2
////////////////////////////////

fn parse_numbers_3_p2(col: Int, number_lines: List(String), text: String) -> Int {
  case number_lines {
    [] -> case int.parse(string.trim(text)) {
      Ok(n) -> n
      Error(_) -> 0
    }
    [first_line, ..rest_lines] -> parse_numbers_3_p2(col, rest_lines, string.slice(first_line, col, 1) <> text)
  }
}

fn parse_numbers_2_p2(number_lines: List(String), range: List(Int), next: List(Int)) -> List(List(Int)) {
  case range {
    [] -> []
    [i, ..rest] -> case parse_numbers_3_p2(i, number_lines, "") {
      0 -> [next, ..parse_numbers_2_p2(number_lines, rest, [])]
      x -> parse_numbers_2_p2(number_lines, rest, [x, ..next])
    }
  }
}
fn parse_numbers_p2(number_lines: List(String)) -> List(List(Int)) {
  let range = list.range(0, case number_lines {
    [] -> 0
    [first, .._rest] -> string.length(first)
  })
  parse_numbers_2_p2(number_lines, range, [])
}

fn parse_lines_p2(lines: List(String), number_lines: List(String)) -> #(List(String),List(List(Int))) {
  case lines {
    [] -> #([], [])
    [last_row] -> #(parse_type(string.trim(last_row)), parse_numbers_p2(number_lines))
    [first, ..rest] -> {
      parse_lines_p2(rest, [first, ..number_lines])
    }
  }
}

fn parse_p2(filepath: String) -> Result(#(List(String),List(List(Int))), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> {
      let #(types, numbers) = parse_lines_p2(split(trim(content), "\n"), [])
      Ok(#(types, numbers))
    }
    Error(_) -> Error("Failed to read file")
  }
}


pub fn part2(filepath: String) -> Result(Int, String) {
  case parse_p2(filepath) {
    Ok(#(types,numbers)) -> {
      Ok(solve_p1(types,numbers,0))
    }
    Error(x) -> Error(x)
  }
}
