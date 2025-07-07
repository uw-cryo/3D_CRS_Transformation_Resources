# Contributing Guide

Contributions are welcome here!

- Report problems, suggest clarifications or submit ideas for new content as a [GitHub Issue](https://github.com/uw-cryo/3D_CRS_Transformation_Resources/issues). The rest of this document details suggestions for making changes to the existing code.

## Fork this repository

We recommend first forking this repository and creating a local copy:

```bash
git clone https://github.com/YOURACCOUNT/3D_CRS_Transformation_Resources.git
cd 3D_CRS_Transformation_Resources
```

## Setup a software environment

You can recreate the software environment that we use to run all the examples in this online book with [Pixi](https://pixi.sh/latest/installation/)

```bash
pixi shell
gdalinfo --version
```

## Add content

Develop your new content on a branch. See [JupyterBook Docs](https://jupyterbook.org/en/stable/intro.html) for guides on adding `.md`, `.ipynb` and other content.

```bash
git checkout -b newcontent
```

## Preview your changes

Myst will execute notebooks and render HTML pages for the website. Be sure to fix any execution errors and preview the website in your web browser to make sure everything looks good!

```bash
pixi run serve
```

NOTE: you can also run `pixi run build` to build without opening a server and browser window.

Happy with how things look? Finally, open a pull request to merge you changes:

## Open a pull request

```bash
git add .
git commit -m "added pages x,y and improved z"
git push
```

Follow the link reported in a terminal to open a pull request!

##  Other potentially useful commands

### Clear cache

Note the following clears all! Run `myst clean --help` to see more granular options

```
pixi run clear-cache
```

### Build a PDF

MystMD is designed to generated different outputs using templates. There are however [lots of open issues dealing with PDF exports](https://github.com/search?q=repo%3Ajupyter-book%2Fmystmd+pdf&type=issues&p=4). In any case, this can be useful if you want a print copy of *all pages* and don't care too much about the style.

This requires that you have `latex` installed see (https://mystmd.org/guide/creating-pdf-documents)

```bash
pixi run pdf
```

NOTE: on macos ARM this proved to be fairly complicated, it seems as of mystmd 1.5 there is better support for *single article* exports. But also worth paying attention to the docs going forward as there are many options it seems for going from markdown -> PDF via latex. Here is what worked for me:

1. Install BasicTex.pkg from https://www.tug.org/mactex/morepackages.html
2. Install various utilities and styles that seem to be required

```bash
sudo tlmgr update --self
sudo tlmgr install latexmk
sudo tlmgr install datetime
sudo tlmgr install fmtcount
sudo tlmgr install framed
sudo tlmgr install glossaries
sudo tlmgr install changepage
sudo tlmgr install enumitem
```

### Check all links

```bash
pixi run linkcheck
```
