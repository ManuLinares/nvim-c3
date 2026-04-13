if exists("b:current_syntax")
  finish
endif

syn keyword c3Keyword fn struct macro import module return var mut in foreach for if else switch case default break continue defer asm def fault try catch do while typeid sizeof alignof offsetof string nextcase anyfault
syn keyword c3Type int char void bool float double i8 i16 i32 i64 u8 u16 u32 u64 isize usize f16 f32 f64 f128 any TYPEID CString String
syn keyword c3Boolean true false null

syn match c3Comment "//.*$"
syn region c3BlockComment start="/\*" end="\*/"

syn region c3String start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match c3Number "\<[0-9]\+\>"
syn match c3Number "\<0[xX][0-9a-fA-F]\+\>"

hi def link c3Keyword Keyword
hi def link c3Type Type
hi def link c3Boolean Boolean
hi def link c3Comment Comment
hi def link c3BlockComment Comment
hi def link c3String String
hi def link c3Number Number

let b:current_syntax = "c3"
