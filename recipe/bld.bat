setlocal EnableDelayedExpansion

%PYTHON% build.py --verbose --no_magic --jobs=%CPU_COUNT% --prefix=%PREFIX% build_wx install_wx
if errorlevel 1 exit 1

%PYTHON% build.py --verbose --use_syswx --jobs=%CPU_COUNT% --prefix=%PREFIX% build_py install_py
if errorlevel 1 exit 1
