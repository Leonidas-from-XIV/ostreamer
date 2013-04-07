(*
* ErrorMonad - a simple error monad implementation for OCaml
* Copyright (C) 2013 Marek Kubica <marek@xivilization.net>
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version,
* with the special exception on linking described in file COPYING.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*)

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
