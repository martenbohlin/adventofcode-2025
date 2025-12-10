import simplifile
import gleam/string.{split,trim}
import gleam/list
import gleam/int

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

fn line(data: List(#(Int,Int)), result:  List(#( #(Int,Int), #(Int,Int) ))) -> List(#( #(Int,Int), #(Int,Int) )) {
  case data {
    [] -> result
    [last] -> {
      case result |> list.reverse() |> list.take(1) {
        [#(fist, _)] -> [ #(last, fist) , ..result]
        _ -> []
      }
    }
    [first, second, ..rest] -> {
      line([second, ..rest], [ #(first, second) , ..result])
    }
  }
}

// Overlapping is false, true if they cross each other
fn intersects(line1: #( #(Int,Int), #(Int,Int) ), line2: #( #(Int,Int), #(Int,Int) )) -> Bool {
  let #( #(x1,y1), #(x2,y2) ) = line1
  let #( #(x3,y3), #(x4,y4) ) = line2
  case line1.0 == line2.0 || line1.1 == line2.1 || line1.0 == line2.1 || line1.1 == line2.0 {
    True -> False // does not intersect it self nor directly connect to the other line
    False -> {
      case x3 == x4, y3 == y4 {
        False, False -> panic as "Only horizontal and vertical lines are supported"
        _, _ -> 0
      }

      case x1 == x2, y1 == y2 {
        True, False -> int.min(x3, x4) <= x1 && int.max(x3, x4) >= x1 && int.min(y1, y2) <= y3 && int.max(y1, y2) >= y3
        False, True -> int.min(y3, y4) <= y1 && int.max(y3, y4) >= y1 && int.min(x1, x2) <= x3 && int.max(x1, x2) >= x3
        _, _ -> panic as "Only horizontal and vertical lines are supported"
      }
    }
  }
}

fn inside_all(box: List(#(Int,Int)), lines: List(#( #(Int,Int), #(Int,Int) ))) -> Bool {
  case box {
    [ #(px1,py1), #(px2,py2) ] -> {
      let bl1 = #(#(px1, py1), #(px1, py2))
      let bl2 = #(#(px1, py1), #(px2, py1))
      let bl3 = #(#(px2, py2), #(px2, py1))
      let bl4 = #(#(px2, py2), #(px1, py2))
      list.all(lines, fn(line) {!{intersects(line, bl1) || intersects(line, bl2) || intersects(line, bl3) || intersects(line, bl4)}})
    }
    _ -> False
  }
}

fn solve_p2(data: List(#(Int,Int))) -> Result(Int, String) {
  let lines = line(data, [])
  case data
  |> list.combinations(2)
  |> list.filter(inside_all(_, lines))
  |> list.map(area)
  |> list.sort(int.compare)
  |> list.reverse() {
    [largest, .._] -> Ok(largest)
    [] -> Error("No areas calculated")
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p2(data)
    Error(x) -> Error(x)
  }
}
