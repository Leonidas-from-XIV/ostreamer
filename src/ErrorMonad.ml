type 'a t =
  | Success of 'a
  | Failure of int * string
let return x = Success x
let bind m f = match m with
  | Success(x) -> f x
  | Failure(i,s) -> Failure(i,s)
