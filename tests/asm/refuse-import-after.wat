;; refuse: an import after a definition
(module (func $f) (import "m" "g" (func $g)))
