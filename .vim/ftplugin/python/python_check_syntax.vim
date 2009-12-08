" vim: ts=4 shiftwidth=4 expandtab fdm=marker
" author: tocer tocer.deng@gmail.com
" version: 0.6.2
" lastchange: 2008-12-17


if !has('python')
    echohl ErrorMsg | echomsg "Required vim compiled with +python" | echohl None
    finish
endif

" the following is python code {{{
python << eof

import vim
if vim.eval('exists("g:pcs_hotkey")') == '0':
    key_check = '<LocalLeader>cs'
else:
    key_check = vim.eval('g:pcs_hotkey')
if vim.eval('exists("g:pcs_check_when_saving")') == '0':
    check_when_saving = True
else:
    check_when_saving = vim.eval('g:pcs_check_when_saving')

cmd_check = 'noremap <buffer> %s :py pysyntaxchecker.check()<CR>' % key_check
vim.command(cmd_check)
if check_when_saving:
    filename = """vim.eval("expand('<afile>:p')")"""
    cmd = 'autocmd BufWritePost *.py py pysyntaxchecker.check(%s)' % filename
    vim.command(cmd)
    cmd = 'autocmd BufLeave *.py py quickfix.close()'
    vim.command(cmd)

eof
" }}}

if exists("g:loaded_pysyntaxchecker")
    finish
endif
let g:loaded_pysyntaxchecker=1

" the following is python code {{{
python << end

import vim
import compiler
try:
    from pyflakes.checker import Checker
except:  # pyflakes version <= 0.2.1
    from pyflakes import Checker

class VimFunction(object):
    def __getattr__(self, name):
        self.func_name = name
        return self.call

    def call(self, *args):
        _args = ','.join([repr(arg) for arg in args])
        return vim.eval('%s(%s)' % (self.func_name, _args))

vimfunc = VimFunction()

class VimQuickFix(object):
    def __init__(self):
        if vimfunc.exists("g:pcs_max_win_height"):
            self.max_height = 10
        else:
            self.max_height = vim.eval('g:pcs_max_win_height')

    def open(self):
        self.close()
        h = len(vimfunc.getqflist())
        if h:
            height = min(h, self.max_height)
            vim.command("copen %d" % height)
        else:
            self.close()

    def close(sel):
        vim.command("cclose")

    def make(self, msgs):
        if msgs:
            keys = ['filename', 'lnum', 'text', 'type']
            # errors = [dict(zip(keys, msg)) for msg in msgs if None not in msg] 
            errors = [dict(zip(keys, msg)) for msg in msgs]
            vimfunc.setqflist(errors, 'r')
            self.open()
        else:
            self.close()

quickfix = VimQuickFix()

class PySyntaxChecker(object):
    def check(self, filename=None):
        if not filename:
            filename = vim.eval("expand('%:p')")
        source = open(filename, 'r').read()
        print >> open('/tmp/vim.log', 'a'), filename, source
        msgs = []
        try:
            tree = compiler.parse(source)
        except (SyntaxError, IndentationError), e:
            msgs.append((filename, e.lineno, e.args[0], 'E'))
        except Exception, e:
            msgs.append((filename, 1, e.args[0], 'E'))
        else:
            w = Checker(tree, filename)
            w.messages.sort(lambda a, b: cmp(a.lineno, b.lineno))
            for msg in w.messages:
                msgs.append((filename, msg.lineno, msg.message % msg.message_args, 'W'))

        quickfix.make(sorted(msgs))


    # NOT IMPLEMENT COMPLETELY
    def pep8check(self, filename, message):
        """
        Parse command line options and run checks on Python source.
        """
        from modules import pep8
        from optparse import OptionParser
        import os
        #from modules import Globals
        
        #pref = Globals.pref
        
        class MyPep8(pep8.Checker):
            def report_error(self, line_number, offset, text, check):
                message.append((self.filename, line_number, text))
                
        options = None
        usage = "%prog [options] input ..."
        parser = OptionParser(usage)
        parser.add_option('-v', '--verbose', default=0, action='count',
                          help="print status messages, or debug with -vv")
        parser.add_option('-q', '--quiet', default=0, action='count',
                          help="report only file names, or nothing with -qq")
        parser.add_option('--exclude', metavar='patterns', default=pep8.default_exclude,
                          help="skip matches (default %s)" % pep8.default_exclude)
        parser.add_option('--filename', metavar='patterns',
                          help="only check matching files (e.g. *.py)")
        parser.add_option('--ignore', metavar='errors', default='',
                          help="skip errors and warnings (e.g. E4,W)")
        parser.add_option('--repeat', action='store_true',
                          help="show all occurrences of the same error")
        parser.add_option('--show-source', action='store_true',
                          help="show source code for each error")
        parser.add_option('--show-pep8', action='store_true',
                          help="show text of PEP 8 for each error")
        parser.add_option('--statistics', action='store_true',
                          help="count errors and warnings")
        parser.add_option('--benchmark', action='store_true',
                          help="measure processing speed")
        parser.add_option('--testsuite', metavar='dir',
                          help="run regression tests from dir")
        parser.add_option('--doctest', action='store_true',
                          help="run doctest on myself")
        options, args = parser.parse_args([filename])
        pep8.options = options
        if options.doctest:
            import doctest
            return doctest.testmod()
        if options.testsuite:
            args.append(options.testsuite)
        if len(args) == 0:
            parser.error('input not specified')
        options.prog = os.path.basename(sys.argv[0])
        options.exclude = options.exclude.split(',')
        for index in range(len(options.exclude)):
            options.exclude[index] = options.exclude[index].rstrip('/')
        if options.filename:
            options.filename = options.filename.split(',')
        if options.ignore:
            options.ignore = options.ignore.split(',')
        else:
            options.ignore = []
        options.counters = {}
        options.messages = {}
    #    if pref.py_check_skip_long_line:
    #        pep8.maximum_line_length = None
    #    if pref.py_check_skip_tailing_whitespace:
    #        pep8.trailing_whitespace = None
    #    if pref.py_check_skip_blank_lines:
    #        pep8.blank_lines = None
        MyPep8(filename).check_all()

pysyntaxchecker = PySyntaxChecker()

end
" }}}
