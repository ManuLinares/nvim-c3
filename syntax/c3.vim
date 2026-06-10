if exists("b:current_syntax")
  finish
endif

syn match c3Identifier  display "\v<_*[a-z][A-Za-z0-9_]*>"
syn match c3Function    display "\zs\w\+\ze\s*("
syn match c3Macro       display "@\zs\w\+\ze\s*("
syn match c3UserAttr    display "@_*[A-Z][A-Z0-9_]*[a-z][a-zA-Z0-9_]*"
syn match c3GlobalConst display "\v<_*[A-Z][A-Z0-9_]+>"
syn match c3UserType    display "\v<_*[A-Z][A-Z0-9_]*[a-z][a-zA-Z0-9_]*>"
syn match c3Label       display "^\s*_*[A-Z][A-Z0-9_]\+:"
syn match c3ComptimeId  display "\v\$<_*[a-z][A-Za-z0-9_]*>"

syn match c3Number display "\v<0[Xx][0-9A-Fa-f](_*[0-9A-Fa-f])*([iu](8|16|32|64|128)|[uU]?[lL]{1,2}|[uU])?>"
syn match c3Number display "\v<0[Oo][0-7](_*[0-7])*([iu](8|16|32|64|128)|[uU]?[lL]{1,2}|[uU])?>"
syn match c3Number display "\v<0[Bb][01](_*[01])*([iu](8|16|32|64|128)|[uU]?[lL]{1,2}|[uU])?>"
syn match c3Number display "\v<[0-9](_*[0-9])*([iu](8|16|32|64|128)|[uU]?[lL]{1,2}|[uU])?>"

syn match c3Float display "\v<[0-9](_*[0-9])*[Ee][+-]?[0-9]+((f|F)(16|32|64|128)?)?>"
syn match c3Float display "\v<0[Xx][0-9A-Fa-f](_*[0-9A-Fa-f])*[Pp][+-]?[0-9]+((f|F)(16|32|64|128)?)?>"
syn match c3Float display "\v<[0-9](_*[0-9])*\.[0-9](_*[0-9])*([Ee][+-]?[0-9]+)?((f|F)(16|32|64|128)?)?>"
syn match c3Float display "\v<0[Xx][0-9A-Fa-f](_*[0-9A-Fa-f])*\.[0-9A-Fa-f](_*[0-9A-Fa-f])*([Pp][+-]?[0-9]+)?((f|F)(16|32|64|128)?)?>"

syn match c3Operator display "\v\.\.\.?|\.\?|\?\?\?"
syn match c3Operator display "\v(\<\<|\>\>|[<>=!+*/%&~^|-])\=?"
syn match c3Operator display "\v\+\+\+\=?|\+\+|--|\&\&\&?|\|\|\|?|\?\?|::|\?:|\=>|[\[]<|>[\]]|\$\$"

syn match c3Delimiter display "\v[;,:\{\}\(\)\[\].?]"

syn match c3HexBytes "\v<x'([\_s]?[0-9A-Fa-f][\_s0-9A-Fa-f]+)+'"
syn match c3HexBytes "\v<x\"([\_s]?[0-9A-Fa-f][\_s0-9A-Fa-f]+)+\""
syn match c3HexBytes "\v<x`([\_s]?[0-9A-Fa-f][\_s0-9A-Fa-f]+)+`"

syn match c3Base64 "\v<b64'([\_s]?[A-Za-z0-9+/][\_sA-Za-z0-9+/]+)+(\=|\=\=)?'"
syn match c3Base64 "\v<b64\"([\_s]?[A-Za-z0-9+/][\_sA-Za-z0-9+/]+)+(\=|\=\=)?\""
syn match c3Base64 "\v<b64`([\_s]?[A-Za-z0-9+/][\_sA-Za-z0-9+/]+)+(\=|\=\=)?`"

syn match c3String display "\v\"(\\.|[^\\\"])*\""
syn region c3String start="\v`" end="\v`"

syn region c3Comment start="\v/\*"   end="\v\*/" contains=c3Comment,c3Todo
syn region c3Comment start="\v//"    end="\v$"   contains=c3Todo
syn region c3Comment start="\v/\*\*" end="\v\*/" contains=c3Contract,c3Todo

syn match c3Contract contained "\v\@require>"
syn match c3Contract contained "\v\@ensure>"
syn match c3Contract contained "\v\@param\s+\[(in|out|inout)\]"
syn match c3Contract contained "\v\@pure>"

syn keyword c3Todo todo Todo TODO contained

" Compiler Constants
syn match c3CompilerConst display "\v\$\$[A-Z0-9_]+>"

" TODO: Comment nesting

syn keyword c3Keyword
      \ assert asm bitstruct break case
      \ catch const continue alias
      \ default defer typedef do
      \ else enum extern
      \ for foreach foreach_r fn
      \ tlocal if inline import
      \ macro module nextcase
      \ return static struct switch
      \ try union var
      \ while attrdef faultdef constdef
      \ interface

syn keyword c3Repeat
      \ do while
      \ for foreach foreach_r
      \ continue break

syn keyword c3Specifier extern inline static tlocal
syn keyword c3Specifier var const

syn keyword c3BuiltinType typeid void any fault anyfault bool
syn keyword c3BuiltinType ichar short  int  long  int128  sz iptr
syn keyword c3BuiltinType char  ushort uint ulong uint128 usz uptr
syn keyword c3BuiltinType float16 bfloat16 float double float128
syn keyword c3BuiltinType untypedlist Char16 Char32
syn keyword c3BuiltinType string zstring wstring dstring

syn keyword c3Null null
syn keyword c3Boolean true false

syn match c3BuiltinAttr display "\v\@align>"
syn match c3BuiltinAttr display "\v\@benchmark>"
syn match c3BuiltinAttr display "\v\@bigendian>"
syn match c3BuiltinAttr display "\v\@builtin>"
syn match c3BuiltinAttr display "\v\@callconv>"
syn match c3BuiltinAttr display "\v\@cdecl>"
syn match c3BuiltinAttr display "\v\@cname>"
syn match c3BuiltinAttr display "\v\@compact>"
syn match c3BuiltinAttr display "\v\@const>"
syn match c3BuiltinAttr display "\v\@deprecated>"
syn match c3BuiltinAttr display "\v\@dynamic>"
syn match c3BuiltinAttr display "\v\@export>"
syn match c3BuiltinAttr display "\v\@extname>"
syn match c3BuiltinAttr display "\v\@finalizer>"
syn match c3BuiltinAttr display "\v\@format>"
syn match c3BuiltinAttr display "\v\@if>"
syn match c3BuiltinAttr display "\v\@init>"
syn match c3BuiltinAttr display "\v\@inline>"
syn match c3BuiltinAttr display "\v\@interface>"
syn match c3BuiltinAttr display "\v\@link>"
syn match c3BuiltinAttr display "\v\@littleendian>"
syn match c3BuiltinAttr display "\v\@local>"
syn match c3BuiltinAttr display "\v\@maydiscard>"
syn match c3BuiltinAttr display "\v\@mustinit>"
syn match c3BuiltinAttr display "\v\@naked>"
syn match c3BuiltinAttr display "\v\@noalias>"
syn match c3BuiltinAttr display "\v\@nodiscard>"
syn match c3BuiltinAttr display "\v\@noinit>"
syn match c3BuiltinAttr display "\v\@noinline>"
syn match c3BuiltinAttr display "\v\@nopadding>"
syn match c3BuiltinAttr display "\v\@norecurse>"
syn match c3BuiltinAttr display "\v\@noreturn>"
syn match c3BuiltinAttr display "\v\@nosanitize>"
syn match c3BuiltinAttr display "\v\@nostrip>"
syn match c3BuiltinAttr display "\v\@obfuscate>"
syn match c3BuiltinAttr display "\v\@operator>"
syn match c3BuiltinAttr display "\v\@optional>"
syn match c3BuiltinAttr display "\v\@overlap>"
syn match c3BuiltinAttr display "\v\@packed>"
syn match c3BuiltinAttr display "\v\@priority>"
syn match c3BuiltinAttr display "\v\@private>"
syn match c3BuiltinAttr display "\v\@public>"
syn match c3BuiltinAttr display "\v\@pure>"
syn match c3BuiltinAttr display "\v\@reflect>"
syn match c3BuiltinAttr display "\v\@safemacro>"
syn match c3BuiltinAttr display "\v\@section>"
syn match c3BuiltinAttr display "\v\@stdcall>"
syn match c3BuiltinAttr display "\v\@tag>"
syn match c3BuiltinAttr display "\v\@test>"
syn match c3BuiltinAttr display "\v\@unused>"
syn match c3BuiltinAttr display "\v\@used>"
syn match c3BuiltinAttr display "\v\@veccall>"
syn match c3BuiltinAttr display "\v\@wasm>"
syn match c3BuiltinAttr display "\v\@weak>"
syn match c3BuiltinAttr display "\v\@weaklink>"
syn match c3BuiltinAttr display "\v\@winmain>"

syn match c3ComptimeKw display "\v\$assert>"
syn match c3ComptimeKw display "\v\$case>"
syn match c3ComptimeKw display "\v\$default>"
syn match c3ComptimeKw display "\v\$defined>"
syn match c3ComptimeKw display "\v\$echo>"
syn match c3ComptimeKw display "\v\$else>"
syn match c3ComptimeKw display "\v\$embed>"
syn match c3ComptimeKw display "\v\$exec>"
syn match c3ComptimeKw display "\v\$expand>"
syn match c3ComptimeKw display "\v\$endfor>"
syn match c3ComptimeKw display "\v\$endforeach>"
syn match c3ComptimeKw display "\v\$endif>"
syn match c3ComptimeKw display "\v\$endswitch>"
syn match c3ComptimeKw display "\v\$eval>"
syn match c3ComptimeKw display "\v\$error>"
syn match c3ComptimeKw display "\v\$feature>"
syn match c3ComptimeKw display "\v\$for>"
syn match c3ComptimeKw display "\v\$foreach>"
syn match c3ComptimeKw display "\v\$if>"
syn match c3ComptimeKw display "\v\$include>"
syn match c3ComptimeKw display "\v\$reflect>"
syn match c3ComptimeKw display "\v\$stringify>"
syn match c3ComptimeKw display "\v\$switch>"
syn match c3ComptimeKw display "\v\$vaarg>"
syn match c3ComptimeKw display "\v\$Typefrom>"
syn match c3ComptimeKw display "\v\$Typeof>"

hi def link c3Number        Number
hi def link c3Float         Number
hi def link c3Identifier    Identifier
hi def link c3ComptimeId    Identifier
hi def link c3CompilerConst Constant

if hlexists('@namespace')
  hi def link c3UserAttr     @namespace
  hi def link c3BuiltinAttr  @namespace
else
  hi def link c3UserAttr     Special
  hi def link c3BuiltinAttr  Special
endif

hi def link c3Function     Function
hi def link c3Macro        Macro
hi def link c3BuiltinType  Type
hi def link c3Label        Label
hi def link c3UserType     Type
hi def link c3Keyword      Keyword
hi def link c3ComptimeKw   Keyword
hi def link c3Specifier    StorageClass
hi def link c3Repeat       Repeat
hi def link c3Boolean      Boolean
hi def link c3Null         Boolean
hi def link c3GlobalConst  Constant
hi def link c3String       String
hi def link c3HexBytes     String
hi def link c3Base64       String
hi def link c3Operator     Operator
hi def link c3Delimiter    Delimiter
hi def link c3Comment      Comment
hi def link c3Contract     Comment

let b:current_syntax = "c3"
