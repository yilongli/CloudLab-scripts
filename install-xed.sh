#!/bin/bash
git clone https://github.com/intelxed/mbuild
git clone https://github.com/intelxed/xed
cd xed
mkdir obj
cd obj
# TODO: `prefix` is not working at all... need to manually copy `xed/kits/xed-install-base-2017-03-17-lin-x86-64/*` to `/usr/local`?
../mfile.py prefix=/usr/local
sudo ../mfile.py prefix=/usr/local install

