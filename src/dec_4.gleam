import simplifile
import gleam/string.{split,trim}
import gleam/list
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
    Error(_) -> "."
  }
}

fn check(data: glearray.Array(String), x: Int, y: Int) -> Int {
  case map(data, x, y) {
    "@" -> 1
    _ -> 0
  }
}

fn remove_paper_roll(data: glearray.Array(String), x: Int, y: Int) -> glearray.Array(String) {
  case glearray.get(data,y) {
    Ok(old_row) -> {
      let new_row = string.slice(old_row, 0, x) <> "." <> string.slice(old_row, x + 1, string.length(old_row) - x - 1)
      case glearray.copy_set(data, y, new_row) {
        Ok(new_data) -> new_data
        Error(_) -> {
          echo "Error"
          glearray.from_list([])
        }
      }
    }
    Error(_) -> {
      echo "Error"
      glearray.from_list([])
    }
  }
}

fn check_row(data: glearray.Array(String), xs: List(Int), y: Int, agregate: Int, next_data: glearray.Array(String)) -> #(Int, glearray.Array(String)) {
  case xs {
    [] -> #(agregate, next_data)
    [x, ..rest_x] -> {
      let #(inc, next_data2) = case map(data, x, y) {
        "@" -> {
          let r1 = check(data, x-1, y-1) + check(data, x, y-1) + check(data, x+1, y-1)
          let r2 = check(data, x-1, y)   +                       check(data, x+1, y)
          let r3 = check(data, x-1, y+1) + check(data, x, y+1) + check(data, x+1, y+1)
          case r1 + r2 + r3 < 4 {
            True -> #(1, remove_paper_roll(next_data, x, y))
            False -> #(0, next_data)
          }
        }
        _ -> #(0, next_data)
      }
      check_row(data, rest_x, y, agregate + inc, next_data2)
    }
  }
}

fn check_rows(data: glearray.Array(String), xs: List(Int), ys: List(Int), agregate: Int, next_data: glearray.Array(String)) -> #(Int, glearray.Array(String)) {
  case ys {
    [] -> #(agregate, next_data)
    [y, ..rest_y] -> {
      let #(inc, next_data2) = check_row(data, xs, y, 0, next_data)
      check_rows(data, xs, rest_y, agregate + inc, next_data2)
    }
  }
}

fn solve_p1(data: glearray.Array(String)) -> Result(Int, String) {
  let xs = list.range(0, case glearray.get(data,0) {
    Ok(s) -> string.length(s) - 1
    Error(_) -> 0
  })
  let ys = list.range(0, glearray.length(data) - 1)
  let #(result, _) = check_rows(data, xs, ys, 0, data)
  Ok(result)
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data)
    Error(x) -> Error(x)
  }
}

fn solve_p2(data: glearray.Array(String), xs: List(Int), ys: List(Int), agregate: Int) -> Result(Int, String) {
  let #(result, next_data) = check_rows(data, xs, ys, 0, data)
  case result {
    0 ->  Ok(agregate)
    _ -> solve_p2(next_data, xs, ys, agregate + result)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> {
      let xs = list.range(0, case glearray.get(data,0) {
        Ok(s) -> string.length(s) - 1
        Error(_) -> 0
      })
      let ys = list.range(0, glearray.length(data) - 1)

      solve_p2(data, xs, ys, 0)
    }
    Error(x) -> Error(x)
  }
}
