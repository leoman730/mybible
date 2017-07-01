# My Bible

http://bible.elab.io


## Usage
```bash
./transform.sh hb5_origin/exo Exodus
```

### Transform a single chapter.  
```bash
./replace.sh hb5_origin/exo/exo32.htm Exodus
```

### Combine all chapters into one.    
```bash
gls -v transformed/hb5_origin/exo/* | xargs cat  > exo.txt
```

## Dependency
GNU coreutils
```bash
# Install coreutils so that we can use gls -v for natural sorting number within text
brew install coreutils
```
