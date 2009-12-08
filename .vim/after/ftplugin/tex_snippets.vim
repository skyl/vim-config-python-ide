if !exists('loaded_snippet') || &cp
  finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

" Original snippets
exec "Snippet sub \\subsection{".st."name".et."}\\label{sub:".st."name:substitute(@z,'.','\\l&','g')".et."}<CR>".st.et
exec "Snippet $$ \\[<CR>".st.et."<CR>\\]<CR>".st.et
exec "Snippet ssub \\subsubsection{".st."name".et."}\\label{ssub:".st."name:substitute(@z,'.','\\l&','g')".et."}<CR>".st.et
exec "Snippet itd \\item[".st."desc".et."] ".st.et
exec "Snippet sec \\section{".st."name".et."}\\label{sec:".st."name:substitute(@z,'.','\\l&','g')".et."<CR>".st.et

" The following snippets were kindly provided by jhradilek
" Document classes:
exec "Snippet article     \\documentclass[".st.et."]{article}<CR>".st.et
exec "Snippet book        \\documentclass[".st.et."]{book}<CR>".st.et
exec "Snippet report      \\documentclass[".st.et."]{book}<CR>".st.et
exec "Snippet letter      \\documentclass[".st.et."]{letter}<CR>".st.et
exec "Snippet slides      \\documentclass[".st.et."]{slides}<CR>".st.et

" Document packages:
exec "Snippet package     \\usepackage[".st.et."]{".st."package".et."}<CR>".st.et

" Document title:
exec "Snippet author      \\author{".st."text".et."}<CR>".st.et
exec "Snippet title       \\title{".st."text".et."}<CR>".st.et
exec "Snippet date        \\date{".st."text".et."}<CR>".st.et

" Document body:
exec "Snippet document    \\begin{document}<CR>".st.et."<CR>\\end{document}"

" Document structure:
exec "Snippet part        \\part{".st."title".et."}<CR>".st.et
exec "Snippet chapter     \\chapter{".st."title".et."}<CR>".st.et
exec "Snippet section     \\section{".st."title".et."}<CR>".st.et
exec "Snippet ssection    \\subsection{".st."title".et."}<CR>".st.et
exec "Snippet sssection   \\subsubsection{".st."title".et."}<CR>".st.et
exec "Snippet paragraph   \\paragraph{".st."title".et."}<CR>".st.et
exec "Snippet sparagraph  \\subparagraph{".st."title".et."}<CR>".st.et
exec "Snippet part*       \\part*{".st."title".et."}<CR>".st.et
exec "Snippet chapter*    \\chapter*{".st."title".et."}<CR>".st.et
exec "Snippet section*    \\section*{".st."title".et."}<CR>".st.et
exec "Snippet ssection*   \\subsection*{".st."title".et."}<CR>".st.et
exec "Snippet sssection*  \\subsubsection*{".st."title".et."}<CR>".st.et
exec "Snippet paragraph*  \\paragraph*{".st."title".et."}<CR>".st.et
exec "Snippet sparagraph* \\subparagraph*{".st."title".et."}<CR>".st.et

" Text environments:
exec "Snippet center      \\begin{center}<CR>".st.et."<CR>\\end{center}<CR>".st.et
exec "Snippet flushleft   \\begin{flushleft}<CR>".st.et."<CR>\\end{flushleft}<CR>".st.et
exec "Snippet flushright  \\begin{flushright}<CR>".st.et."<CR>\\end{flushright}<CR>".st.et
exec "Snippet comment     \\begin{comment}<CR>".st.et."<CR>\\end{comment}<CR>".st.et
exec "Snippet quote       \\begin{quote}<CR>".st.et."<CR>\\end{quote}<CR>".st.et
exec "Snippet quotation   \\begin{quotation}<CR>".st.et."<CR>\\end{quotation}<CR>".st.et
exec "Snippet verse       \\begin{verse}<CR>".st.et."<CR>\\end{verse}<CR>".st.et
exec "Snippet verbatim    \\begin{verbatim}<CR>".st.et."<CR>\\end{verbatim}<CR>".st.et
exec "Snippet verbatim*   \\begin{verbatim*}<CR>".st.et."<CR>\\end{verbatim*}<CR>".st.et
exec "Snippet multicols   \\begin{multicols}{".st."n".et."}<CR>".st.et."<CR>\\end{multicols}<CR>".st.et

" Lists:
exec "Snippet enumerate   \\begin{enumerate}<CR>".st.et."<CR>\\end{enumerate}<CR>".st.et
exec "Snippet itemize     \\begin{itemize}<CR>".st.et."<CR>\\end{itemize}<CR>".st.et
exec "Snippet description \\begin{description}<CR>".st.et."<CR>\\end{description}<CR>".st.et
exec "Snippet item        \\item ".st."text".et."<CR>".st.et
exec "Snippet itemx       \\item[".st."x".et."] ".st."text".et."<CR>".st.et

" References:
exec "Snippet label       \\label{".st."marker".et."}".st.et
exec "Snippet ref         \\ref{".st."marker".et."}".st.et
exec "Snippet pageref     \\pageref{".st."marker".et."}".st.et
exec "Snippet footnote    \\footnote{".st."text".et."}".st.et

" Floating bodies:
exec "Snippet table       \\begin{table}[".st."place".et."]<CR>".st.et."<CR>\\end{table}<CR>".st.et
exec "Snippet figure      \\begin{figure}[".st."place".et."]<CR>".st.et."<CR>\\end{figure}<CR>".st.et
exec "Snippet equation    \\begin{equation}[".st."place".et."]<CR>".st.et."<CR>\\end{equation}<CR>".st.et
exec "Snippet caption     \\caption{".st."text".et."}<CR>".st.et

" Tabular environments:
exec "Snippet tabbing     \\begin{tabbing}<CR>".st.et."<CR>\\end{tabbing}<CR>".st.et
exec "Snippet tabular     \\begin{tabular}[".st."pos".et."]{".st."cols".et."}<CR>".st.et."<CR>\\end{tabular}<CR>".st.et
exec "Snippet tabular*    \\begin{tabular*}{".st."width".et."}[".st."pos".et."]{".st."cols".et."}<CR>".st.et."<CR>\\end{tabular*}<CR>".st.et
exec "Snippet cline       \\cline{".st."range".et."}".st.et
exec "Snippet multicolumn \\multicolumn{".st."n".et."}{".st."cols".et."}{".st."text".et."}".st.et

" Typefaces:
exec "Snippet emph        \\emph{".st."text".et."}".st.et
exec "Snippet textrm      \\textrm{".st."text".et."}".st.et
exec "Snippet textsf      \\textsf{".st."text".et."}".st.et
exec "Snippet texttt      \\texttt{".st."text".et."}".st.et
exec "Snippet textmd      \\textmd{".st."text".et."}".st.et
exec "Snippet textbf      \\textbf{".st."text".et."}".st.et
exec "Snippet textup      \\textup{".st."text".et."}".st.et
exec "Snippet textit      \\textit{".st."text".et."}".st.et
exec "Snippet textsl      \\textsl{".st."text".et."}".st.et
exec "Snippet textsc      \\textsc{".st."text".et."}".st.et
