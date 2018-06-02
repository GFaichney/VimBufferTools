let g:InputProcessor = {'currStr':''}

function! g:InputProcessor.New(...)
  let newObj = copy(self)
  if a:0 && type(a:1) == type({})
    let newObj.callbacks = deepcopy(a:1)
  else
    let newObj.callbacks = {}
  endif
  return newObj
endfunction

function! g:InputProcessor.DoTextChangeCallback()
  if has_key(self.callbacks, 'onChange')
    let a:Callback = function(self.callbacks['onChange'])
    call a:Callback(self.currStr)
  endif
endfunction

function! g:InputProcessor.RemoveLastChar() dict
  let self.currStr = self.currStr[0:strlen(self.currStr)-2]
  call self.DoTextChangeCallback()
endfunction

function! g:InputProcessor.ProcessInput() dict
  let a:c = ""
  while a:c != "\<up>"
    let a:c = getchar()
    if a:c != "\<up>"
      if !has_key(self.callbacks, a:c)
        if a:c == "\<BS>"
          call self.RemoveLastChar()
        else
          let a:cmod = getcharmod()
          if a:cmod > 1   "Ignore most keys starting with ctrl/alt etc
            feedkeys(a:c)
          else 
            call self.OnPrintableCharacter(nr2char(a:c))
          endif
        endif
      else
        let a:Callback = function(self.callbacks[a:c])
        call a:Callback()
      endif
    endif
  endwhile
endfunction

function! g:InputProcessor.OnPrintableCharacter(word) dict
  let self.currStr = self.currStr . a:word
  call self.DoTextChangeCallback()
endfunction  

function! g:InputProcessor.ReadLine() dict
  call self.ProcessInput()
endfunction

"""""""""""""""""""""""""""""""""""""""""

function! CallDown()
  echo "Down pressed!"
  call feedkeys("\<C-W>\<C-W>")
endfunction

function! WordChangeCallback(word)
  echo "Word: " . a:word
endfunction

function! RunMe()
  let inputProcessor = g:InputProcessor.New({"\<down>":'CallDown', "onChange": 'WordChangeCallback'})
  call inputProcessor.ReadLine()
endfunction
