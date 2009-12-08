if !exists('loaded_snippet') || &cp
  finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

" The following snippets were kindly provided by jhradilek
exec "Snippet shebang #!/usr/bin/env lua<CR>".st.et
exec "Snippet do do<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet for for ".st."variable".et." = ".st."start".et.", ".st."end".et." do<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet fori for ".st."variable".et." in ".st."iterator".et." do<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet fors for ".st."variable".et." = ".st."start".et.", ".st."end".et.", ".st."step".et." do<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet function function ".st."name".et."(".st.et.")<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet ifee if ".st."expression".et." then<CR>".st.et."<CR>elseif ".st."expression".et." then<CR>".st.et."<CR>else<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet ife if ".st."expression".et." then<CR>".st.et."<CR>else<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet if if ".st."expression".et." then<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet lfunction local function ".st."name".et."(".st.et.")<CR>".st.et."<CR>end<CR>".st.et
exec "Snippet repeat repeat<CR>".st.et."<CR>until ".st."expression".et."<CR>".st.et
exec "Snippet while while ".st."expression".et." do<CR>".st.et."<CR>end<CR>".st.et
