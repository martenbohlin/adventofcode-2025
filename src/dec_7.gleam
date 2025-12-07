import simplifile
import gleam/string.{split,trim}
import gleam/list
import gleam/set.{type Set}
import gleam/dict.{type Dict}
import gleam/option.{type Option, Some, None}

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

fn dict_inc(x: Int) -> fn(Option(Int)) -> Int {
  fn(old: Option(Int)) -> Int {
    case old {
      Some(v) -> v + x
      None -> x
    }
  }
}

// beams is a map column index => how many timelines passes through that column
fn beam_splits_p2(beams: Dict(Int,Int), splitters: List(String)) -> Int {
  case splitters {
    [] -> beams |> dict.fold(0, fn(aggregate, _beam, time_lines) {
      aggregate + time_lines
    })
    [current_splitters, ..rest] -> {
      let new_beams = beams |> dict.fold(dict.new(), fn(next_beams, beam, time_lines) {
        case beam_split(beam, current_splitters) {
          True -> {
            //#([beam - 1, beam + 1, ..next_beams], splits + 1)
            next_beams |> dict.upsert(beam-1, dict_inc(time_lines)) |> dict.upsert(beam+1, dict_inc(time_lines))
          }
          _ -> {
            next_beams |> dict.upsert(beam, dict_inc(time_lines))
          }
        }
      })
      beam_splits_p2(new_beams, rest)
    }
  }
}

fn solve_p2(data: List(String)) -> Result(Int, String) {
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
      Ok(beam_splits_p2(dict.new() |> dict.insert(start, 1), rest))
    }
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> {
      solve_p2(data)
    }
    Error(x) -> Error(x)
  }
}
