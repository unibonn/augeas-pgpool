(*
Module: Pgconf
  Parses pgconf.conf

Author: Alex Schultz <aschultz@next-development.com>

About: Reference
   http://www.pgpool.net/docs/latest/pgpool-en.html

About: Configuration files
   This lens applies to pgconf.conf. See <filter>.

About: Examples
   The <Test_Pgpool> file contains various examples and tests.
*)


module Pgpool =
  autoload xfm

(* View: sep
     Key and values are separated
     by either spaces or an equal sign *)
let sep = del /([ \t]+)|([ \t]*=[ \t]*)/ " = "

(* Variable: bool_word_re
     The boolean words from the pgpool configuration (on|off) *)
let bool_word_re = /on|off/

(* Variable: number_re
     An integer only *)
let number_re = Rx.integer

(* View: number
     Storing <number_re>, with or without quotes *)
let number = store number_re

(* View: bool_word
     Store the <bool_word_re> without quotes *)
let bool_word = store bool_word_re

(* View: word_quot
     Anything other than <bool_word_re> or <number>
     Quotes are mandatory *)
let word_quot =
     let esc_squot = /\\\\'/
  in let no_quot = /[^#'\n]/
  in let forbidden = number_re | bool_word_re
  in let value = (no_quot|esc_squot)* - forbidden
  in Quote.do_squote (store value)

(* View: entry_gen
     Builder to construct entries *)
let entry_gen (lns:lens) =
  Util.indent . Build.key_value_line_comment Rx.word sep lns Util.comment_eol

(* View: entry *)
let entry = entry_gen number
          | entry_gen bool_word
          | entry_gen word_quot    (* anything else *)

(* View: lns *)
let lns = (Util.empty | Util.comment | entry)*

(* Variable: filter *)
let filter = (incl "/etc/pgpool/pgpool.conf"
                 .incl "/etc/pgpool-II-*/pgpool.conf")

let xfm = transform lns filter