(* Simple equivalent of the Error Monad from Haskell.
 *
 * The relationship goes like this:
 * Maybe Monad <=> option type
 * Error Monad <=> this
 *)
type 'a t =
  | Success of 'a
  | Failure of int * string
let return x = Success x
let bind m f = match m with
  | Success(x) -> f x
  | Failure(i, s) -> Failure(i, s)

(* this module is short by intention to allow 'open'ing without overwriting too
 * much code. *)
