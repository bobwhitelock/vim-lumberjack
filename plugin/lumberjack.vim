
map gl <Plug>(operator-print-below)
call operator#user#define('print-below', 'OperatorPrintBelow')
function! OperatorPrintBelow(motion_wise)
  call s:handle_operator_print(a:motion_wise, 'o')
endfunction

map gL <Plug>(operator-print-above)
call operator#user#define('print-above', 'OperatorPrintAbove')
function! OperatorPrintAbove(motion_wise)
  call s:handle_operator_print(a:motion_wise, 'O')
endfunction

function! s:handle_operator_print(motion_wise, enter_insert_char)
  if !exists('b:print_string')
    echoerr "'b:print_string' not defined for current buffer"
    return
  endif

  normal! mz

  let motion_text = s:yank_last_motion(a:motion_wise)
  let print_string = s:template_print_string(b:print_string, motion_text)
  execute 'normal!' a:enter_insert_char . print_string

  normal! `z
endfunction

function! s:yank_last_motion(motion_wise)
  let visual_command = operator#user#visual_command_from_wise_name(a:motion_wise)

  let original_selection = &g:selection
  let &g:selection = 'inclusive'
  execute 'normal!' '`[' . visual_command . '`]"zy'
  let &g:selection = original_selection

  return @z
endfunction

function! s:template_print_string(print_string, value)
  let identifier = a:value . ' [' . s:random_string(8) . ']'
  let identifier_replaced = substitute(a:print_string, 'IDENTIFIER', identifier, 'g')
  let value_replaced = substitute(identifier_replaced, 'VALUE', a:value, 'g')
  return value_replaced
endfunction

" Generate random string of lowercase ASCII chars of given length.
function! s:random_string(length)
  let a_code = char2nr('a')
  let z_code = char2nr('z')

  let chars = []
  while len(chars) < a:length
    let code = s:pseudo_random_integer_between(a_code, z_code)
    call add(chars, nr2char(code))
  endwhile

  return join(chars, '')
endfunction

" Generate pseudo-random integer between given values (inclusive).
" Adapted from https://vi.stackexchange.com/a/3840.
function! s:pseudo_random_integer_between(min, max)
  let range = a:max - a:min + 1
  let random_int = str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
  let int_in_range = random_int % range
  return int_in_range + a:min
endfunction
