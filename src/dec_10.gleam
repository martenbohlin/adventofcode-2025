import simplifile
import gleam/deque.{type Deque,pop_front,push_back}
import gleam/list
import gleam/dict.{type Dict}
import gleam/int
import gleam/io.{println_error}
import gleam/order.{type Order, Eq, Lt, Gt}
import gleam/string.{split,trim}
import glearray.{type Array}
import gleam/option.{Some, None}

fn pares_lights(light_diagram: String, result: Array(Bool)) -> Array(Bool) {
  case light_diagram {
    "" -> result
    "." <> rest -> pares_lights(rest, glearray.copy_push(result, False))
    "#" <> rest -> pares_lights(rest, glearray.copy_push(result, True))
    "[" <> rest -> pares_lights(rest, result)
    "]"  <> rest -> pares_lights(rest, result)
    _ -> panic as {"Invalid light diagram character: " <> light_diagram}
  }
}

fn parse_numbers(numbers: String) -> List(Int) {
  case string.split(string.slice(numbers, 0, string.length(numbers) - 1), ",") {
    [] -> []
    ns -> list.map(ns, fn (n) { case int.parse(n) {
      Ok(n) -> n
      Error(_) -> panic as {"Invalid number format: " <> n}
    }})
  }
}

fn parse_buttons(rest: List(String), buttons: List(List(Int)), joltage: List(Int)) -> #(List(List(Int)), List(Int)) {
  case rest {
    [] -> #(buttons, joltage)
    ["(" <> numbers, ..tail] -> parse_buttons(tail, [parse_numbers(numbers), ..buttons], joltage)
    ["{" <> numbers, ..tail] -> parse_buttons(tail, buttons, parse_numbers(numbers))
    _ -> panic as {"Invalid button format in"}
  }
}

fn parse_line(line: String) -> #(Array(Bool), List(List(Int)), List(Int)) {
  case split(line, " ") {
    [light_diagram, ..rest] -> {
      let x = parse_buttons(rest, [], [])
      #(pares_lights(light_diagram, glearray.new()),x.0,x.1)
    }
    _ -> panic as {"Invalid line format " <> line}
  }
}

fn parse(filepath: String) -> Result(List(#(Array(Bool), List(List(Int)), List(Int))), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> Ok(split(trim(content), "\n") |> list.map(parse_line))
    Error(_) -> Error("Failed to read file")
  }
}

fn toggle_lights(current_lights: Array(Bool), button: List(Int)) -> Array(Bool) {
  case button {
    [] -> current_lights
    [index, ..rest] -> {
      case glearray.get(current_lights, index) {
        Ok(state) -> {
          let new = case glearray.copy_set(current_lights, index, !state) {
            Ok(updated) -> updated
            Error(_) -> panic as {"Button index out of bounds: " <> int.to_string(index)}
          }
          toggle_lights(new, rest)
        }
        Error(_) -> panic as {"Button index out of bounds: " <> int.to_string(index)}
      }
    }
  }
}

fn breadth_first_search(wanted_lights:Array(Bool), all_buttons: List(List(Int)), queue: Deque(#(Array(Bool), Int, List(Int)))) -> Int {
  case pop_front(queue) {
    Ok(#(#(current_lights, presses, button), queue)) -> {
      let new_lights = toggle_lights(current_lights, button)
      case new_lights == wanted_lights {
        True -> presses
        False -> {
          let new_queue = list.fold(all_buttons, queue, fn (agregate, button) {
            push_back(agregate, #(new_lights, presses + 1, button))
          })
          breadth_first_search(wanted_lights, all_buttons, new_queue)
        }
      }
    }
    Error(_) -> panic as {"No solution found"}
  }
}

fn solve_p1(data: List(#(Array(Bool), List(List(Int)), List(Int))), aggregate: Int) -> Result(Int, String) {
  case data {
    [] -> Ok(aggregate)
    [#(wanted_lights, buttons, _), ..tail] -> {
      let all_off = wanted_lights |> glearray.to_list |> list.map(fn (_) { False }) |> glearray.from_list()
      let presses = breadth_first_search(wanted_lights, buttons, deque.from_list([#(all_off, 0, [])]))
      echo presses
      solve_p1(tail, aggregate + presses)
    }
  }
}

pub fn part1(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data, 0)
    Error(x) -> Error(x)
  }
}

fn divade_all_by_two(joltage: List(Int)) -> Result(List(Int),Nil) {
  case joltage {
    [] -> Ok([])
    [value, ..tail] -> case int.remainder(value, 2) {
      Ok(0) -> case divade_all_by_two(tail) {
        Ok(v) -> Ok([value / 2, ..v])
        Error(_) -> Error(Nil)
      }
      _ -> Error(Nil)
    }
  }
}

fn compare_to_zeros(joltage: List(Int)) -> Order {
  list.fold(joltage, order.Eq, fn(aggregate, value) {
    case aggregate {
      order.Eq -> case value {
        0 -> order.Eq
        x if x > 0 -> order.Gt
        _ -> order.Lt
      }
      order.Lt -> order.Lt
      order.Gt -> case value {
        0 -> order.Gt
        x if x > 0 -> order.Gt
        _ -> order.Lt
      }
    }
  })
}

fn pattern_key(joltage: Array(Int)) -> List(Int) {
  glearray.to_list(joltage) |> list.map(fn (x) { x % 2 })
}

// Pre calculates all combinations where each button is pressed 0 or 1 time
// And return a Dict with joltages that go from even to odd as a key and joltage changes and button presses as value
fn button_combinations(buttons: List(List(Int)), nr_joltages: Int) -> Dict(List(Int), List(#(Array(Int), Int))) {
  let possible_button_combinations = list.range(0, list.length(buttons)) |> list.fold([], fn(aggregate, n) {
    list.append(list.combinations(list.range(0, list.length(buttons) - 1), n), aggregate)
  })

  let button_a = glearray.from_list(buttons)

  possible_button_combinations |> list.fold(dict.new(), fn(aggregate, buttons) {
    let start_joltage_array = list.range(0, nr_joltages - 1) |> list.map(fn(_) {0}) |>glearray.from_list()
    let delta_joltage = list.fold(buttons, start_joltage_array, fn(aggregate, button_index) {
      let button = case glearray.get(button_a, button_index) {
        Ok(b) -> b
        Error(_) -> panic as {"Button index out of bounds: " <> int.to_string(button_index)}
      }
      list.fold(button, aggregate, fn(aggregate, joltage_index) {
        case glearray.get(aggregate, joltage_index) {
          Ok(delta_joltage) -> case glearray.copy_set(aggregate, joltage_index, delta_joltage + 1) {
            Ok(updated) -> updated
            Error(_) -> panic as {"Joltage index out of bounds: " <> int.to_string(joltage_index)}
          }
          Error(_) -> panic as {"Joltage index out of bounds: " <> int.to_string(joltage_index)}
        }
      } )
      //let joltage_key = glearray.to_list(joltage_change) |> list.map(fn (x) { x % 2 })
    })
    dict.upsert(aggregate, pattern_key(delta_joltage), fn (old) { case old {
      Some(v) -> [#(delta_joltage, list.length(buttons)), ..v]
      None -> [#(delta_joltage, list.length(buttons))]
    }})
  })
}

fn minus(a: List(Int), b: Array(Int)) -> List(Int) {
  list.zip(a, glearray.to_list(b)) |> list.map(fn (x) {
    let #(aval, bval) = x
    aval - bval
  })
}

//
// Solution heavily influenced by https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
//
fn solve_single_line_p2(odd_patterns: Dict(List(Int), List(#(Array(Int), Int))), remaining_joltage:List(Int), buttons: List(List(Int))) -> Result(Int, Nil) {
  case compare_to_zeros(remaining_joltage), divade_all_by_two(remaining_joltage) {
    Eq, _ -> Ok(0)
    Lt, _ -> Error(Nil)
    Gt, _ -> {
      case odd_patterns |> dict.get(pattern_key(glearray.from_list(remaining_joltage))) {
        Ok(options) -> {
          options |> list.fold(Error(Nil), fn(aggregate,option) {
            let #(delta_joltage, button_presses) = option
            let m = minus(remaining_joltage, delta_joltage)
            let new_remaining = case divade_all_by_two(m) {
              Ok(v) -> v
              Error(_) -> panic as "No solution found"
            }
            case aggregate, solve_single_line_p2(odd_patterns, new_remaining, buttons) {
              x, Error(_) -> x
              Error(_), Ok(acc) -> Ok(acc*2 + button_presses)
              Ok(a), Ok(acc) -> Ok(int.min(a, acc*2 + button_presses))
            }
          })
        }
        Error(_) -> Error(Nil)
      }
    }
  }
}

fn solve_p2(data: List(#(Array(Bool), List(List(Int)), List(Int))), aggregate: Int) -> Result(Int, String) {
  case data {
    [] -> Ok(aggregate)
    [#(_, buttons, wanted_joltage), ..tail] -> {
      let presses = case solve_single_line_p2(button_combinations(buttons, list.length(wanted_joltage)), wanted_joltage, buttons) {
        Ok(presses) -> presses
        Error(_) -> panic as "No solution found"
      }
      println_error(string.inspect(#("Result: ", presses, wanted_joltage)))
      solve_p2(tail, aggregate + presses)
    }
  }
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p2(data, 0)
    Error(x) -> Error(x)
  }
}
