# Contributing Guide

Contributions are welcome here!

- Report problems, suggest clarifications or submit ideas for new content as a [GitHub Issue](https://github.com/uw-cryo/3D_CRS_Transformation_Resources/issues). The rest of this document details suggestions for making changes to the existing code.

## Fork this repository

We recommend first forking this repository and creating a local copy:

```
git clone https://github.com/YOURACCOUNT/3D_CRS_Transformation_Resources.git
cd 3D_CRS_Transformation_Resources
```

## Setup a software environment

```
You can recreate the software environment that we use to run all the examples in this online book with [Pixi](https://pixi.sh/latest/installation/)

```
pixi shell
gdalinfo --version
```


## Add content

Develop your new content on a branch. See [JupyterBook Docs](https://jupyterbook.org/en/stable/intro.html) for guides on adding `.md`, `.ipynb` and other content.

```
git checkout -b newcontent
```

## Preview your changes

Myst will execute notebooks and render HTML pages for the website. Be sure to fix any execution errors and preview the website in your web browser to make sure everything looks good!

```
pixi run serve
```

NOTE: you can also run `pixi run build` to build without opening a server and browser window.

Happy with how things look? Finally, open a pull request to merge you changes:

## Open a pull request

```
git add .
git commit -m "added pages x,y and improved z"
git push
```

Follow the link reported in a terminal to open a pull request!
