#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

for _ in 1 2; do
  pdflatex \
    -jobname=cv-build \
    -interaction=nonstopmode \
    -halt-on-error \
    cv.tex
done

mv cv-build.pdf CV_Pilny_Tomas.pdf
