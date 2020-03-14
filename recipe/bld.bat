setlocal EnableDelayedExpansion

%PYTHON% build.py --jobs=4 --prefix=%PREFIX% build_wx install_wx
if errorlevel 1 exit 1

%PYTHON% build.py --jobs=4 --prefix=%PREFIX% build_py install_py
if errorlevel 1 exit 1
