open OUnit

let equ = assert_equal

let test_version_getting _ =
        let version = Archive.version_string () in
        let name = String.sub version 0 10 in
        equ name "libarchive"

let suite = "Simple tests" >::: [
        "test_version_getting" >:: test_version_getting
        ]

let _ =
        run_test_tt_main suite
