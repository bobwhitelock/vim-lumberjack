
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
  let print_string = s:print_string()
  if empty(print_string)
    return
  endif

  normal! mz

  let motion_text = s:yank_last_motion(a:motion_wise)
  let rendered_print_string = s:template_print_string(print_string, motion_text)
  execute 'normal!' a:enter_insert_char . rendered_print_string

  normal! `z
endfunction

function! s:print_string()
  if exists('b:lumberjack_print_string')
    return b:lumberjack_print_string
  elseif exists('b:lumberjack_default_print_string')
    return b:lumberjack_default_print_string
  else
    echoerr "No 'b:lumberjack_print_string' or 'b:lumberjack_default_print_string' defined for current buffer."
  endif
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
  let token = s:random_string(8)

  let identifier = a:value
  if s:include_random_token()
    let identifier .= ' [' . token . ']'
  endif

  let values_map = {
        \ 'VALUE': a:value,
        \ 'TOKEN': token,
        \ 'IDENTIFIER': identifier
        \}

  return s:template_string(a:print_string, values_map)
endfunction

function! s:include_random_token()
  if exists('g:lumberjack_include_random_token')
    return g:lumberjack_include_random_token
  else
    return v:true
  endif
endfunction

" Replace keys in string using values in values_map; see
" https://stackoverflow.com/a/766093/2620402 for explanation of this
" technique.
function! s:template_string(string, values_map)
  let regex = join(keys(a:values_map), '\|')
  let substitution =  '\=' . string(a:values_map) . '[submatch(0)]'
  return substitute(a:string, regex, substitution, 'g')
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
