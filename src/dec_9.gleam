import simplifile
import gleam/string.{split,trim}
import gleam/list
import gleam/dict.{type Dict}
import gleam/int
import gleam/float

fn parse(filepath: String) -> Result(List(#(Int,Int)), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> Ok(split(trim(content), "\n") |> list.fold([], fn(agregate, line) {
      case split(line, ",") {
        [x,y] -> [case int.parse(x), int.parse(y) {
          Ok(ix), Ok(iy) -> #(ix, iy)
          _, _ -> #(-1,-1)
}, ..agregate]
        _ -> agregate
      }
    }) |> list.reverse())
    Error(_) -> Error("Failed to read file")
  }
}

fn area(pair: List(#(Int,Int))) -> Int {
  case pair {
    [ #(x1,y1), #(x2,y2) ] -> {int.absolute_value(x2 - x1) + 1} * {int.absolute_value(y2 - y1) + 1}
    _ -> -1
  }
}

fn solve_p1(data: List(#(Int,Int))) -> Result(Int, String) {
  case data
  |> list.combinations(2)
  |> list.map(area)
  |> list.sort(int.compare)
  |> list.reverse() {
    [largest, .._] -> Ok(largest)
    [] -> Error("No areas calculated")
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data)
    Error(x) -> Error(x)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> {
      Ok(0)
    }
    Error(x) -> Error(x)
  }
}
