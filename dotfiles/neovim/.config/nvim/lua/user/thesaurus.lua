vim.opt.thesaurusfunc = 'Thesaur'

vim.cmd [[
func Thesaur(findstart, base)
    if a:findstart
	let line = getline('.')
	let start = col('.') - 1
	while start > 0 && line[start - 1] =~ '\a'
	   let start -= 1
	endwhile
	return start
    else
	let res = []
	let h = ''
	for l in split(system('aiksaurus '.shellescape(a:base)), '\n')
	    if l[:3] == '=== '
	    	let h = substitute(l[4:], ' =*$', '', '')
	    elseif l[0] =~ '\a'
		call extend(res, map(split(l, ', '), {_, val -> {'word': val, 'menu': '('.h.')'}}))
	    endif
	endfor
	return res
    endif
endfunc
]]
