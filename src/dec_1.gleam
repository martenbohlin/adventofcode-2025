import simplifile
import gleam/string.{split,trim}
import gleam/int
//import gleam/io.{println}

fn parse(filepath: String) {
  let c = simplifile.read(from: filepath)

  case c {
    Ok(content) -> split(trim(content), "\n")
    Error(_) -> []
  }
}
fn count_cliks(start: Int, num: Int) -> Int {
  case start {
    100 -> num / 100
    _ ->{start + num} / 100
  }
}

fn rotate(start: Int, direction: String) -> Result(#(Int, Int), String) {
  case direction {
    "R" <> amount -> case int.parse(amount) {
      Ok(n) ->case int.modulo(start + n, 100) {
        Ok(x) -> Ok(#(x, count_cliks(start, n)))
        Error(_) -> Error("Modulus failed")
      }
      Error(_) -> Error("Parse failed")
    }
    "L" <> amount -> case int.parse(amount) {
      Ok(n) -> case int.modulo(start - n, 100) {
        Ok(x) -> Ok(#(x, count_cliks(100-start, n)))
        Error(_) -> Error("Modulus failed")
      }
      Error(_) -> Error("Parse failed")
    }
    x -> {
      Error("Invalid direction: " <> x)
    }
  }
}

fn rotate_all(start: Int, directions: List(String)) -> Result(#(Int, Int), String) {
  case directions {
    [] -> {
      //println("Final Pos: " <> int.to_string(start))
      Ok(#(0,0))
    }
    [first, ..rest] -> {
      let x = rotate(start, first)
      //echo x
      let rot_result = case x {
        Ok(#(0, inc_part2)) -> Ok(#(0, 1, inc_part2))
        Ok(#(new_start, inc_part2)) -> Ok(#(new_start, 0, inc_part2))
        Error(x) -> Error(x)
      }

      case rot_result {
        Ok(#(new_start, inc_part1, inc_part2)) -> {
          //println("Direction: " <> first <> "  " <> int.to_string(start) <> " -> " <> int.to_string(new_start) <> " Part2: " <> int.to_string(inc_part2))
          case rotate_all(new_start, rest) {
            Ok(#(part1, part2)) -> {
              Ok(#(part1 + inc_part1, part2 + inc_part2))
            }
            Error(x) -> Error(x)
          }
        }
        Error(x) -> Error(x)
      }
    }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  let data = parse(filepath)
  case rotate_all(50, data) {
    Ok(#(part1, _)) -> Ok(part1)
    Error(x) -> Error(x)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  let data = parse(filepath)
  case rotate_all(50, data) {
    Ok(#(_, part2)) -> Ok(part2)
    Error(x) -> Error(x)
  }
}
