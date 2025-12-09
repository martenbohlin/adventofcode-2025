import simplifile
import gleam/string.{split,trim}
import gleam/list
import gleam/dict.{type Dict}
import gleam/int
import gleam/float

fn parse(filepath: String) -> Result(List(#(Float,Float,Float)), String) {
  case simplifile.read(from: filepath) {
    Ok(content) -> Ok(split(trim(content), "\n") |> list.fold([], fn(agregate, line) {
      case split(line, ",") {
        [x,y,z] -> [case int.parse(x), int.parse(y), int.parse(z) {
          Ok(ix), Ok(iy), Ok(iz) -> #(int.to_float(ix), int.to_float(iy), int.to_float(iz))
          _, _, _ -> #(-1.0,-1.0,-1.0)
}, ..agregate]
        _ -> agregate
      }
    }) |> list.reverse())
    Error(_) -> Error("Failed to read file")
  }
}

fn distance(a: #(Float,Float,Float), b: #(Float,Float,Float)) -> Float {
  let #(ax,ay,az) = a
  let #(bx,by,bz) = b

  let dx = ax -. bx
  let dy = ay -. by
  let dz = az -. bz

  case float.square_root(dx*.dx +. dy*.dy +. dz*.dz) {
    Ok(d) -> d
    Error(_) -> -1.0
  }
}

fn group(pairs: List(#(Float, #(Float,Float,Float), #(Float,Float,Float))), aggregate: Dict(#(Float,Float,Float), List(#(Float,Float,Float)))) -> Dict(#(Float,Float,Float), List(#(Float,Float,Float))) {
  case pairs {
    [] -> aggregate
    [ #(_,a,b), ..rest ] -> {
      let #(lista, listb) = case dict.get(aggregate, a), dict.get(aggregate, b) {
        Ok(lista), Ok(listb) -> #(lista, listb)
        Error(_), Ok(listb) -> #([], listb)
        Ok(lista), Error(_) -> #(lista, [])
        Error(_), Error(_) -> #([], [])
      }
      let new_group = [a,b, ..lista |> list.append(listb)] |> list.unique()

      group(rest, dict.fold(aggregate, aggregate, fn(aggregate, key, _) {
        case new_group |> list.contains(key) {
          True -> dict.insert(aggregate, key, new_group)
          False -> aggregate
        }
      })
        |> dict.insert(a, new_group)
        |> dict.insert(b, new_group)
      )
    }
  }
}

fn solve_p1(data: List(#(Float,Float,Float)), connections: Int) -> Result(Int, String) {
  echo list.combinations(data,2)
  |> list.fold([], fn(agregate, pair) {
    case pair {
      [a,b] -> {
        let d = distance(a,b)
        [ #(d, a,b), ..agregate]
      }
      _ -> agregate
    }
  })
  |> list.sort(fn (a, b) {
    float.compare(a.0, b.0)
  })
  |> list.take(connections)
  |> group(dict.new())
  |> dict.fold([], fn(agregate, _key, value) {
    [value, ..agregate]
  })
  |> list.unique()
  |> list.sort(fn (a, b) {
    int.compare(list.length(b), list.length(a))
  })
  |> list.map(fn(group) {
    list.length(group)
  })
  |> list.take(3)
  |> list.fold(1, fn(agregate, x) {
    agregate * x
  })
  |> Ok
}

pub fn part1(filepath: String, connections: Int) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> solve_p1(data, connections)
    Error(x) -> Error(x)
  }
}

fn group_p2(pairs: List(#(Float, #(Float,Float,Float), #(Float,Float,Float))), nr_jboxes: Int, aggregate: Dict(#(Float,Float,Float), List(#(Float,Float,Float)))) -> Int {
  case pairs {
    [] -> -1
    [ #(_,a,b), ..rest ] -> {
      let #(lista, listb) = case dict.get(aggregate, a), dict.get(aggregate, b) {
        Ok(lista), Ok(listb) -> #(lista, listb)
        Error(_), Ok(listb) -> #([], listb)
        Ok(lista), Error(_) -> #(lista, [])
        Error(_), Error(_) -> #([], [])
      }
      let new_group = [a,b, ..lista |> list.append(listb)] |> list.unique()
      case list.length(new_group) == nr_jboxes {
        True -> {
          echo nr_jboxes
          echo new_group
          echo a
          echo b
          float.truncate(a.0) * float.truncate(b.0)
        }
        False -> group_p2(rest, nr_jboxes, dict.fold(aggregate, aggregate, fn(aggregate, key, _) {
          case new_group |> list.contains(key) {
            True -> dict.insert(aggregate, key, new_group)
            False -> aggregate
          }
        }
        )
        |> dict.insert(a, new_group)
        |> dict.insert(b, new_group)
        )
      }
    }
  }
}


fn solve_p2(data: List(#(Float,Float,Float))) -> Result(Int, String) {
  echo list.combinations(data,2)
  |> list.fold([], fn(agregate, pair) {
    case pair {
      [a,b] -> {
        let d = distance(a,b)
        [ #(d, a,b), ..agregate]
      }
      _ -> agregate
    }
  })
  |> list.sort(fn (a, b) {
    float.compare(a.0, b.0)
  })
  |> group_p2(list.length(data), dict.new())
  |> Ok
}

pub fn part2(filepath: String) -> Result(Int, String) {
  case parse(filepath) {
    Ok(data) -> {
      solve_p2(data)
    }
    Error(x) -> Error(x)
  }
}
