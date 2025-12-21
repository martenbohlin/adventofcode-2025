import simplifile
import gleam/string.{split,trim}
import gleam/int
import gleam/list
import glearray.{type Array, copy_push}
import gleam/io.{println_error,print_error}
import gleam/option.{type Option, Some, None}
import gleam/bool
import gleam/set
import rememo/memo

pub type Present {
  Present(shape: String, area: Int, width: Int, length: Int, alternatives: List(List(#(Int, Int))), common: #(Int, Int))
}

fn present_area(block: String) -> Int {
  string.to_graphemes(block)
  |> list.filter(fn(c) { c == "#" })
  |> list.length()
}

fn occupied(block: String, width: Int, height: Int, coordinate: #(Int, Int)) -> Bool {
  let #(x, y) = coordinate
  case x < 0 || x >= width || y < 0 || y >= height {
    True  -> True
    False -> {
      let index = y * {width + 1} + x // +1 for newline
      case string.slice(block, index, 1) {
        "." -> False
        " " -> False
        _   -> True
      }
    }
  }
}

fn mirror_occupies(occupied: List(#(Int, Int)), width: Int) -> List(#(Int, Int)) {
  occupied |> list.map(fn(coordinate) {
    let #(x, y) = coordinate
    #(width - 1 - x, y)
  })
}

fn rotate_occupies(occupied: List(#(Int, Int)), width: Int, _height: Int) -> List(#(Int, Int)) {
  occupied |> list.map(fn(coordinate) {
    let #(x, y) = coordinate
    #(y, width - 1 - x)
  })
}

fn all_rotations(occupied: List(#(Int, Int)), width: Int, height: Int) -> List(List(#(Int, Int))) {
  let r1 = occupied
  let r2 = rotate_occupies(r1, width, height)
  let r3 = rotate_occupies(r2, height, width)
  let r4 = rotate_occupies(r3, width, height)
  [r1, r2, r3, r4]
}

fn parse_present(block: String) -> Present {
  let shape_list = list.drop(split(trim(block), "\n"),1)
  let shape = shape_list |> string.join("\n")
  let width = case shape_list |> list.first() {
    Ok(row)  -> string.length(row)
    Error(_) -> 0
  }
  let height = list.length(shape_list)
  let occupied = combinations(list.range(0, height-1), list.range(0, width-1))
  |> list.filter(fn (coordinate) { occupied(shape, width, height, coordinate) })

  let occupies = set.from_list(all_rotations(occupied, width, height))
  |> set.union(set.from_list(all_rotations(mirror_occupies(occupied, width), width, height)))
  |> set.to_list()

  let first = case list.first(occupies) {
    Ok(o) -> o
    Error(_) -> panic as {"Present has no occupies"}
  }

  let common = first |> list.fold(None, fn(aggregate, coordinate) {
    case aggregate {
      None -> {
        case list.all(occupies, fn(o) { list.contains(o, coordinate)}) {
          True -> Some(coordinate)
          False -> None
        }
      }
      Some(x) -> Some(x)
    }
  })

  let c = case common {
    Some(v) -> v
    None -> panic as {"Present has no common occupy"}
  }

  Present(shape, present_area(shape), width, height, occupies, c)
}

fn parse_present_count(str: String) -> Array(Int) {
  string.split(str,  " ") |> list.map(fn(n) {
    case int.parse(n) {
      Ok(num) -> num
      Error(_) -> panic as {"Invalid present count: " <> n}
    }
  }) |> glearray.from_list
}

fn parse_regions(block: String) -> List(#(Int, Int, Array(Int))) {
  split(trim(block), "\n") |> list.map(fn(line) {
    case string.split(line, ": ") {
      [start_str, end_str] -> {
        case string.split(start_str, "x") {
          [width, length] -> {
            case int.parse(width), int.parse(length) {
              Ok(w), Ok(l) -> #(w, l, parse_present_count(end_str))
              _, _ -> panic as {"Invalid region width: " <> width <> ", length: " <> length}
            }
          }
          _ -> panic as {"Invalid region start: " <> start_str}
        }
      }
      _ -> panic as {"Invalid region format: " <> line}
    }
  })
}

fn parse_blocks(blocks: List(String), parsed_presets: Array(Present)) -> Result(#(Array(Present), List(#(Int, Int, Array(Int)))), String) {
  case blocks {
    [] -> Error("No blocks to parse")
    [last] -> Ok(#(parsed_presets, parse_regions(last)))
    [head, ..tail] -> parse_blocks(tail, copy_push(parsed_presets, parse_present(head)))
  }
}

fn parse(filepath: String) -> Result(#(Array(Present), List(#(Int, Int, Array(Int)))), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> parse_blocks(split(trim(content), "\n\n"), glearray.new())
    Error(_) -> Error("Failed to read file")
  }
}

fn combined_present_area(presents: Array(Present), indices: Array(Int)) -> Int {
  glearray.to_list(indices) |> list.index_fold(0, fn(aggregate, count, index) {
    case glearray.get(presents, index) {
      Ok(present) -> aggregate + present.area * count
      Error(_) -> aggregate
    }
  })
}

pub fn combinations(xs: List(a), ys: List(a)) -> List(#(a, a)) {
  xs |> list.flat_map(fn(x) {
    ys |> list.map(fn(y) { #(x, y) })
  })
}

fn insert_present(region: String, present_occupies: List(#(Int,Int)), x: Int, y: Int, width: Int, length: Int, replacement: String) -> Option(String) {
  let can_fit = present_occupies |> list.all(fn(coordinate) {
    let #(dx, dy) = coordinate
    let rx = x + dx
    let ry = y + dy
    bool.negate(occupied(region, width, length, #(rx, ry)))
  })

  case can_fit {
    True  -> {
      let region = present_occupies |> list.fold(region, fn(aggregate, coordinate) {
        let #(dx, dy) = coordinate
        let rx = x + dx
        let ry = y + dy
        let index = ry * {width + 1} + rx // +1 for newline
        string.slice(aggregate, 0, index) <> replacement <> string.slice(aggregate, index + 1, string.length(aggregate) - index + 1)
      })
      Some(region) // Return updated region (placeholder)
    }
    False -> None
  }
}

fn add(c1: #(Int, Int), c2: #(Int, Int)) -> #(Int, Int) {
  #(c1.0 + c2.0, c1.1 + c2.1)
}

fn pussle(width: Int, length: Int, region: String, presents: List(Present), cache) -> Int {
  use <- memo.memoize(cache, #(region, presents))
  case list.length(presents) {
    x if x > 300 -> {
      println_error("")
      println_error("" <> int.to_string(x))
      println_error(region)
      1
    }
    x if x > 299 -> {
      print_error("-")
      1
    }
    _ -> 2 // No presents to pack we are finally done!
  }
  case presents {
    [] -> {
      println_error("All presents fit into region \n" <> region)
      1 // No presents to pack we are finally done!
    }
    [head, ..tail]  -> {
      combinations(list.range(0, width-1), list.range(0, length-1)) |> list.fold(0, fn(aggregate, coordinate) {
        case aggregate {
          1 -> 1 // Already found a solution
          _ -> {
            case occupied(region, width, length, add(coordinate, head.common)) {
              True  -> aggregate // Do not need to check alternatives
              False -> {
                head.alternatives |> list.fold(0, fn(agg, occupies) {
                  case agg {
                    1 -> 1 // Already found a solution
                    _ -> {
                      let #(x, y) = coordinate
                      case insert_present(region, occupies, x, y, width, length, "X") {
                        Some(new_region) -> pussle(width, length, new_region, tail, cache)
                        None -> 0
                      }
                    }
                  }
                })
              }
            }
          }
        }
      })
    }
  }
}

fn present_list(presents: Array(Present), counts: Array(Int)) -> List(Present) {
  glearray.to_list(counts) |> list.index_fold([], fn(aggregate, count, index) {
    case glearray.get(presents, index) {
      Ok(present) -> {
        let repeated = list.repeat(present, count)
        list.append(aggregate, repeated)
      }
      Error(_) -> panic as {"Invalid present index: " <> int.to_string(index)}
    }
  })
}

fn solve_p1(presents: Array(Present), regions: List(#(Int, Int, Array(Int)))) -> Int {
  case regions {
    [] -> 0
    [#(width, length, present_counts), ..rest] -> {
      let region_area = width * length
      let present_area = combined_present_area(presents, present_counts)
      case region_area >= present_area {
        True  -> {
          let row = string.repeat(".", width)
          let area = list.range(1, length) |> list.map(fn(_) { row }) |> string.join("\n")
          use cache <- memo.create()
          pussle(width, length, area, present_list(presents, present_counts), cache)
        }
        False -> 0 // To small
      } + solve_p1(presents, rest)
    }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> Ok(solve_p1(data.0, data.1))
    Error(x) -> Error(x)
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(_) -> Ok(0)
    Error(x) -> Error(x)
  }
}
