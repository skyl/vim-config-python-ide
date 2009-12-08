function! LoadRope()
python << EOF
import ropevim
ropevim.open_project(".")
EOF
endfunction

:silent call LoadRope()
