import simplifile
import gleam/string.{split,trim}
import gleam/list
import gleam/int
import gleam/dict.{type Dict}
import gleam/set.{type Set}

fn parse_line(line: String) -> #(String, List(String)) {
  case split(line, ": ") {
    [key, values_str] -> #(key, split(values_str, " "))
    _ -> panic as {"Invalid line format: " <> line}
  }
}

fn parse(filepath: String) -> Result(Dict(String, List(String)), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> Ok(split(trim(content), "\n") |> list.map(parse_line) |> list.fold(dict.new(), fn(aggregate, x) {
      let #(key, values) = x
      dict.insert(aggregate, key, values)
    }))
    Error(_) -> Error("Failed to read file")
  }
}

fn solve_p1(device: String, data: Dict(String, List(String))) -> Int {
  case device {
    "out" -> 1
    x -> case dict.get(data, x) {
        Ok(values) -> {
          list.fold(values, 0, fn(aggregate, value) {
            aggregate + solve_p1(value, data)
          })
        }
        Error(_) -> 0
      }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> Ok(solve_p1("you", data))
    Error(x) -> Error(x)
  }
}

fn solve_p2(data: Dict(String, List(String))) -> Result(Int, String) {
  Ok(0)
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p2(data)
    Error(x) -> Error(x)
  }
}
