import simplifile
import gleam/string.{split,trim}
import gleam/int
import gleam/io.{println}
import gleam/list.{length}
import gleam/option.{type Option, Some, None}

fn parse_supply(lines: List(String)) -> List(Int) {
  case lines {
    [] -> []
    [first, ..rest] -> {
      case int.parse(first) {
        Ok(n) -> [n, ..parse_supply(rest)]
        Error(_) -> parse_supply(rest)
      }
    }
  }
}

fn parse_ok(lines: List(String)) -> List(#(Int, Int)) {
  case lines {
    [] -> []
    [head, ..rest] -> {
      case string.split(head, "-") {
        [first, last] -> case int.parse(first), int.parse(last) {
          Ok(f), Ok(l) -> {
            case int.parse(first) {
              Ok(n) -> [#(f, l), ..parse_ok(rest)]
              Error(_) -> parse_ok(rest)
            }
          }
          _, _ -> parse_ok(rest)
        }
        _ -> parse_ok(rest)
      }
    }
  }
}

fn parse(filepath: String) ->  Result(#(List(#(Int,Int)), List(Int)), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> {
      case split(trim(content), "\n\n") {
        [ok_ranges,supply] ->
          Ok(#(parse_ok(split(trim(ok_ranges), "\n")), parse_supply(split(trim(supply), "\n"))))

        _ -> Error("Wrong number of sections")
      }
    }
    Error(_) -> Error("Failed to read file")
  }
}

fn is_ok(ranges: List(#(Int, Int)), supply: Int) -> Int {
  case ranges {
    [] -> 0
    [ #(start, end), ..rest] -> case supply >= start && supply <= end {
      True -> 1
      False -> is_ok(rest, supply)
    }
  }
}

fn solve_p1(data: #(List(#(Int,Int)), List(Int)), aggregate: Int)-> Int {
  case data {
    #(_, []) -> aggregate
    #(ok_ranges, [supply, ..rest]) -> {
      solve_p1(#(ok_ranges, rest), aggregate + is_ok(ok_ranges, supply))
    }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> {
      Ok(solve_p1(data,0))
    }
    Error(x) -> Error(x)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> Ok(0)
    Error(x) -> Error(x)
  }
}
