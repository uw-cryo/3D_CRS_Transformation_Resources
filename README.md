# 3D CRS Transformation Resources

[![Jupyter Book Badge](https://jupyterbook.org/badge.svg)](https://uw-cryo.github.io/3D_CRS_Transformation_Resources/)


A centralized repository for resources, documentation and code samples to help the community navigate the confusing, complex, but very important topic of 3D coordinate reference system (CRS) transformations when combining datasets for precise geodetic analysis.

This repository was initially created for an improptu community tutorial session led by David Shean and Scott Henderson at the 2023 UW/NASA [ICESat-2 Hackweek event](https://icesat-2-2023.hackweek.io/).

We are continuing to review and update materials, including new recipes and examples for commonly used 3D datasets. The best way to navigate the material is via the Jupyter Book website (linked with the button above) or by using this link https://uw-cryo.github.io/3D_CRS_Transformation_Resources/.

## Running code examples

You can launch a [GitHub Codespace](https://github.com/features/codespaces) with a pre-configured environment to run all the examples in this repository:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/uw-cryo/3D_CRS_Transformation_Resources)

```bash
# min specs ok = 2 cores, 8 GB RAM, 32 GB storage
gh codespace create --idle-timeout 30m --repo uw-cryo/3D_CRS_Transformation_Resources --status
```

```bash
gh codespace jupyter
```

```bash
gh codespace stop
```

### Local install


Or if you want to execute code examples on your own machine, we recommend using [pixi.sh](https://pixi.sh/latest/) for managing the Python environment:

```bash
gh clone uw-cryo/3D_CRS_Transformation_Resources
pixi shell --frozen
```

