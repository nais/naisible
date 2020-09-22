#/bin/bash

set -e

cd

if [[ -e $HOME/.bootstrapped ]]; then
  exit 0
fi

PYTHON_VERSION=2.7
PYPY_VERSION=v7.3.1
N_CURSES_LIB=$(ldconfig -p |grep libncurses.so | awk '{print $NF}')

if [[ -e $HOME/pypy$PYTHON_VERSION-$PYPY_VERSION-linux64.tar.bz2 ]]; then
  tar -xjf $HOME/pypy$PYTHON_VERSION-$PYPY_VERSION-linux64.tar.bz2
  rm -rf $HOME/pypy$PYTHON_VERSION-$PYPY_VERSION-linux64.tar.bz2
else
  wget -O - https://bitbucket.org/pypy/pypy/downloads/pypy$PYTHON_VERSION-$PYPY_VERSION-linux64.tar.bz2 |tar -xjf -
fi

mv -n pypy$PYTHON_VERSION-$PYPY_VERSION-linux64 pypy

## library fixup
mkdir -p pypy/lib
ln -snf $N_CURSES_LIB $HOME/pypy/lib/libtinfo.so.5

mkdir -p $HOME/bin

cat > $HOME/bin/python <<EOF
#!/bin/bash
LD_LIBRARY_PATH=$HOME/pypy/lib:$LD_LIBRARY_PATH exec $HOME/pypy/bin/pypy "\$@"
EOF

chmod +x $HOME/bin/python
$HOME/bin/python --version

touch $HOME/.bootstrapped
