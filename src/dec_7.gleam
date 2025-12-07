import simplifile
import gleam/string.{split,trim}
import gleam/list
import gleam/set.{type Set}


fn parse(filepath: String) -> Result(List(String), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> Ok(split(trim(content), "\n"))
    Error(_) -> Error("Failed to read file")
  }
}

fn beam_split(beam, current_splitters) -> Bool {
  case string.slice(current_splitters, beam, 1) {
    "^" -> True
    _ -> False
  }
}

fn beam_splits(beams: Set(Int), splitters: List(String)) -> Int {
  case splitters {
    [] -> 0
    [current_splitters, ..rest] -> {
      let #(new_beams, splits) = set.fold(beams, #(set.new(), 0), fn(agregate, beam) {
        let #(next_beams, splits) = agregate
        case beam_split(beam, current_splitters) {
          True -> {
            #(next_beams |> set.insert(beam - 1) |> set.insert(beam + 1), splits + 1)
          }
          _ -> #(next_beams |> set.insert(beam), splits)
        }
      })
      splits + beam_splits(new_beams, rest)
    }
  }
}

fn solve_p1(data: List(String)) -> Result(Int, String) {
  case data {
    [] -> Error("No data")
    [first, ..rest] -> {
      let start = string.to_graphemes(first) |> list.index_fold(0, fn (agregate, char, index) {
        case char {
          "S" -> {
            index
          }
          _ -> agregate
        }
      })
      Ok(beam_splits(set.from_list([start]), rest))
    }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data)
    Error(x) -> Error(x)
  }
}

fn solve_p2(data: List(String), agregate: Int) -> Result(Int, String) {
  Ok(0)
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> {
      solve_p2(data, 0)
    }
    Error(x) -> Error(x)
  }
}
