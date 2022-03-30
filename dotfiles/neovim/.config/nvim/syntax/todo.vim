" :sort! /+/
" :sort! /@/
" in visual mode select project or context tags and :sort by priority

if exists("b:current_syntax")
    finish
endif

syntax  match  TodoDone       '^[xX]\s.\+$'
syntax  match  TodoDate       '\d\{2,4\}-\d\{2\}-\d\{2\}' contains=NONE
syntax  match  TodoProject    '\(^\|\W\)+[^[:blank:]]\+'  contains=NONE
syntax  match  TodoContext    '\(^\|\W\)@[^[:blank:]]\+'  contains=NONE

highlight  default  link  TodoDone       Comment
highlight  default  link  TodoDate       TSInclude
highlight  default  link  TodoProject    TSTag
highlight  default  link  TodoContext    TSParameter

let b:current_syntax = "todo"
