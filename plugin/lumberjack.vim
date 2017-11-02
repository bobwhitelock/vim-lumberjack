
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
  let print_string = substitute(b:print_string, '%s', motion_text, 'g')
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
