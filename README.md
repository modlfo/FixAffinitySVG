# Fix Affinity SVG

Affinity Designer exports SVG files that do not load correctly in VCV Rack. The main problem is that the <defs> are placed at the end of the file when the renderer of Rack requires them in the beginning.

# Compile

Your require OCaml with at the library `xml-light` and `ocamlbuild`. You can install them using `opam`.

```
$ ocamlbuild -use-ocamlfind fixsvg.byte
```

# Run

To fix a single file:
```
$ fixsvg.byte file.svg
```

To fix all files in a directory

```
$ fixsvg.byte -dir /path/to/files
```
