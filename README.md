# mybible

## Update: New script to transform a book.
```bash
./transform.sh hb5_origin/exo Exodus
```


Transform individual chapter.  
./replace.sh hb5_origin/exo/exo32.htm Exodus


Combine all chapters into one.  
Note: May need to fix ordering.  
cat transformed/hb5_origin/exo/* > exo.txt


## Dependency
GNU coreutils
```bash
# Install coreutils so that we can use gls -v for natural sorting number within text
brew install coreutils
```