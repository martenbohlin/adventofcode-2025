import simplifile
import gleam/deque.{type Deque,pop_front,push_back}
import gleam/list
import gleam/int
import gleam/order
import gleam/set.{type Set}
import gleam/string.{split,trim}
import glearray.{type Array}

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

fn increase_joltage(current_joltage: Array(Int), button: List(Int)) -> Array(Int) {
  case button {
    [] -> current_joltage
    [index, ..rest] -> {
      case glearray.get(current_joltage, index) {
        Ok(value) -> {
          let new = case glearray.copy_set(current_joltage, index, value + 1) {
            Ok(updated) -> updated
            Error(_) -> panic as {"Button index out of bounds: " <> int.to_string(index)}
          }
          increase_joltage(new, rest)
        }
        Error(_) -> panic as {"Button index out of bounds: " <> int.to_string(index)}
      }
    }
  }
}

fn compare_joltage(current_joltage: Array(Int), wanted_joltage: Array(Int)) -> order.Order {
      let comparison = list.zip(glearray.to_list(current_joltage), glearray.to_list(wanted_joltage))
      |> list.fold(order.Eq, fn (agregate, x) {
        let #(current, wanted) = x
        case agregate {
          order.Eq -> int.compare(current, wanted)
          order.Lt -> case int.compare(current, wanted) {
            order.Gt -> order.Gt
            _ -> order.Lt
          }
          order.Gt -> order.Gt
        }
      })
      comparison
}

fn breadth_first_search_p2(wanted_joltage:Array(Int), all_buttons: List(List(Int)), queue: Deque(#(Array(Int), Int, List(Int))), explored: Set(Array(Int))) -> Int {
  case pop_front(queue) {
    Ok(#(#(current_joltage, presses, button), queue)) -> {
      let new_joltage = increase_joltage(current_joltage, button)
      case compare_joltage(new_joltage, wanted_joltage) {
        order.Eq -> presses
        order.Lt -> {
          case set.contains(explored, new_joltage) {
            True -> breadth_first_search_p2(wanted_joltage, all_buttons, queue, explored) // Already explored, skip this path
            False -> {
              let new_queue = list.fold(all_buttons, queue, fn (agregate, button) {
                push_back(agregate, #(new_joltage, presses + 1, button))
              })
              breadth_first_search_p2(wanted_joltage, all_buttons, new_queue, set.insert(explored, new_joltage))
            }
          }
        }
        order.Gt -> breadth_first_search_p2(wanted_joltage, all_buttons, queue, set.insert(explored, new_joltage)) // Out of range, skip this path
      }
    }
    Error(_) -> panic as {"No solution found"}
  }
}

fn solve_p2(data: List(#(Array(Bool), List(List(Int)), List(Int))), aggregate: Int) -> Result(Int, String) {
  case data {
    [] -> Ok(aggregate)
    [#(_, buttons, wanted_joltage), ..tail] -> {
      let all_zero = wanted_joltage |> list.map(fn (_) { 0 }) |> glearray.from_list()
      let presses = breadth_first_search_p2(glearray.from_list(wanted_joltage), buttons, deque.from_list([#(all_zero, 0, [])]), set.new())
      echo #(presses, wanted_joltage)
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
