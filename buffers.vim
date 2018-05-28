let g:BufferToolsBufferName = 'BufferToolsBuffer'


function! GetBufferDisplayFlags(buffer)
  let a:dispFlags = ''
  if empty(a:buffer.changed)
    let a:dispFlags = '-'
  else
    let a:dispFlags = 'M'
  endif

  if empty(a:buffer.loaded)
    let a:dispFlags = a:dispFlags . '|' . 'L'
  else
    let a:dispFlags = a:dispFlags . '|' . '-'
  endif

  return '[' . a:dispFlags . ']'
endfunction


function! GetBufferDisplayString(buffer)
  return a:buffer.bufnr . ' - ' . GetBufferDisplayFlags(a:buffer) . ' ' . a:buffer.name
endfunction 

function! GetBufferDetails()
  let a:blist = []
  let a:buffers = getbufinfo()
  for a:buf in a:buffers
    if !empty(a:buf.listed)
      let a:dstring = GetBufferDisplayString(a:buf)
      if match(a:dstring, g:BufferToolsBufferName) == -1
        call add(a:blist, a:dstring)
      endif
    endif
  endfor

  return a:blist
endfunction

function! GetSelectedBufferNumber()
  let a:currline = getline('.')
  let a:num = matchstr(a:currline, '^\(\d\+\)')
  return a:num
endfunction

function! JumpToSelectedBuffer()
  let a:num = GetSelectedBufferNumber()
  exec t:winStartedFrom . 'wincmd w'
  execute "b" . a:num
  call CloseToolsBuffer()
endfunction

function! DeleteSelectedBuffer()
  let a:num = GetSelectedBufferNumber()
  let a:currbuff = bufnr('%')

  execute "bdelete " . a:num

  call RefreshToolsBufferContents()
endfunction

function! SaveSelectedBuffer()
  let a:num = GetSelectedBufferNumber()
  let a:currbuff = bufnr('%')

  execute "b" . a:num
  execute "w"
  execute "b" . a:currbuff 

  call RefreshToolsBufferContents()
endfunction 

function! RefreshToolsBufferContents()
  " set modifiable

  execute "normal! gg"
  execute "normal! dG"
  call append(line('^'), GetBufferDetails())
  execute "normal! dd"
  stopinsert

  " set nomodifiable
endfunction

function! ToolsBuffer()
  let t:winStartedFrom=winnr()
  new g:BufferToolsBufferName
  wincmd J
  resize 10
  set ft=nofile
  set nonu

  call RefreshToolsBufferContents()
  set cursorline
  set readonly
  nmap <buffer> <CR> :call JumpToSelectedBuffer()<CR>
  nmap <buffer> s :call SaveSelectedBuffer()<CR>
  nmap <buffer> d :call DeleteSelectedBuffer()<CR>
  nmap <buffer> q :call CloseToolsBuffer()<CR>
  nmap <buffer> <c-b> :call CloseToolsBuffer()<CR>

  call EnableToolsBufferAutoCMD()
endfunction

function! GetOpenWindowInfo()

  function! CreateWinObj()
    let a:winobj = {}
    let a:winobj.nr = winnr()
    let a:winobj.name = bufname('%')
    return a:winobj
  endfunction

  let a:oldwin=winnr()
  let a:x=[]
  windo call add(a:x, CreateWinObj())
  exec a:oldwin . 'wincmd w'

  return a:x
endfunction 

function! DisableToolsBufferAutoCMD()
  augroup ToolsBuffer
    au!
  augroup END
endfunction

function! EnableToolsBufferAutoCMD()
  augroup ToolsBuffer
    autocmd!
    "au BufLeave <buffer> call CloseToolsBuffer()
    " TODO
  augroup END
endfunction

function! IsToolsBufferShowing()
  let a:wininf = GetOpenWindowInfo()
  for a:win in a:wininf
    if a:win.name == g:BufferToolsBufferName
      return 1
    endif 
  endfor

  return 0
endfunction

function! CloseToolsBuffer()
  call DisableToolsBufferAutoCMD()
  exec t:winStartedFrom . 'wincmd w'
  execute "bd! " . g:BufferToolsBufferName
endfunction

nmap <c-b> :call ToolsBuffer()<CR>
