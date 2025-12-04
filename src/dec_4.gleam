import simplifile
import gleam/string.{split,trim}
import gleam/int
import gleam/io.{println}
import gleam/list.{length}
import glearray


fn parse(filepath: String) -> Result(glearray.Array(String), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> Ok(glearray.from_list(split(trim(content), "\n")))
    Error(_) -> Error("Failed to read file")
  }
}

fn map(data: glearray.Array(String), x: Int, y: Int) -> String {
  case glearray.get(data,y) {
    Ok(s) -> case x >= 0 && x < string.length(s) {
      True -> string.slice(s,x,1)
      False -> "."
    }
    Error(x) -> "."
  }
}

fn check(data: glearray.Array(String), x: Int, y: Int) -> Int {
  case map(data, x, y) {
    "@" -> 1
    _ -> 0
  }
}

fn check_row(data: glearray.Array(String), xs: List(Int), y: Int, agregate: Int) -> Int {
  case xs {
    [] -> agregate
    [x, ..rest_x] -> {
      let inc = case map(data, x, y) {
        "@" -> {
          let r1 = check(data, x-1, y-1) + check(data, x, y-1) + check(data, x+1, y-1)
          let r2 = check(data, x-1, y)   +                       check(data, x+1, y)
          let r3 = check(data, x-1, y+1) + check(data, x, y+1) + check(data, x+1, y+1)
          let inc = case r1 + r2 + r3 < 4 {
            True -> 1
            False -> 0
          }
        }
        _ -> 0
      }
      check_row(data, rest_x, y, agregate + inc)
    }
  }
}

fn check_rows(data: glearray.Array(String), xs: List(Int), ys: List(Int), agregate: Int) -> Int {
  case ys {
    [] -> agregate
    [y, ..rest_y] -> {
      check_rows(data, xs, rest_y, agregate + check_row(data, xs, y, 0))
    }
  }
}

fn solve_p1(data: glearray.Array(String)) -> Result(Int, String) {
  let xs = list.range(0, case glearray.get(data,0) {
    Ok(s) -> string.length(s) - 1
    Error(_) -> 0
  })
  let ys = list.range(0, glearray.length(data) - 1)
  Ok(check_rows(data, xs, ys, 0))
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data)
    Error(x) -> Error(x)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> Ok(0)
    Error(x) -> Error(x)
  }
}
