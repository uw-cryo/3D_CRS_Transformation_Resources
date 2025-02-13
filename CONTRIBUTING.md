# Contributing Guide

Contributions are welcome here!

- Report bugs, request features or submit feedback as a [GitHub Issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues).


## Fork this repository

We recommend first forking this repository and creating a local copy:

```
git clone https://github.com/YOURACCOUNT/3D_CRS_Transformation_Resources.git
cd xarray-tutorial
```

## Add content

Develop your new content on a branch. See [JupyterBook Docs](https://jupyterbook.org/en/stable/intro.html) for guides on adding `.md`, `.ipynb` and other content.

```
git checkout -b newcontent
```

## Preview your changes

Jupyter Book will execute notebooks and render HTML pages for the website. Be sure to fix any execution errors and preview the website in your web browser to make sure everything looks good!

```
pixi website
```

Happy with how things look? Finally, open a pull request to merge you changes:

## Open a pull request

```
git add .
git commit -m "added pages x,y and improved z"
git push
```

Follow the link reported in a terminal to open a pull request!
