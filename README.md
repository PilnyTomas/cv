# Tomáš Pilný — CV

The CV is maintained in [`cv.tex`](cv.tex); its headshot is the single tracked image at [`assets/profile-photo.jpg`](assets/profile-photo.jpg). Generated PDFs and the supplied reference PDF are not committed.

## Build locally

Requires `pdflatex` and the standard LaTeX packages used in the source.

```sh
./build.sh
```

This produces `CV Pilný Tomáš.pdf`, which is ignored by Git.

## Publish a release

Commit and push the CV changes, then run:

```sh
./release.sh
```

The script summarizes changes since the previous dated release, shows uncommitted paths, and asks for confirmation. The first release of a day gets a `vYYYY-MM-DD` tag; additional releases get `vYYYY-MM-DD-HH-MM`, with seconds added if that tag already exists. It pushes the tag; GitHub Actions builds the PDF and publishes it as `CV Pilný Tomáš.pdf` in a GitHub Release.
Use `./release.sh -f` to skip the confirmation prompt.

The stable latest-release download is:

<https://github.com/PilnyTomas/cv/releases/latest/download/CV%20Piln%C3%BD%20Tom%C3%A1%C5%A1.pdf>

Run the script again after editing `cv.tex` or replacing `assets/profile-photo.jpg` to publish an updated CV under a new date tag.
