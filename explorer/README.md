# Geoid explorer

An interactive page that shows the height of one surface above another on a rotatable globe or an
Equal Earth map: EGM2008 or EGM96 above the WGS 84 ellipsoid, EGM2008 above EGM96, and, as a shape-only
comparison, other ellipsoids placed with the WGS 84 centre and axes. It is a single static page,
`index.html`, with its data in `data/`. It loads d3 7.9.0 and topojson 3.0.2 from cdnjs.

The site build does not process this folder. The deploy workflow copies it to `_build/html/explorer/`
after `pixi run build`, and `essentials/geoid.md` embeds it from there.

## Data

| file | contents | size |
|---|---|---|
| `data/egm2008.png` | EGM2008 geoid height above WGS 84, 2.5' grid thinned to 7.5', in cm | 3.6 MB |
| `data/egm96.png` | EGM96 geoid height above WGS 84, 15' grid, in cm | 1.1 MB |
| `data/countries-50m.json` | Natural Earth 1:50m countries, from `world-atlas` 2.0.2 | 0.8 MB |

The geoid grids come from [PROJ-data](https://github.com/OSGeo/PROJ-data) (`us_nga_egm96_15.tif`,
`us_nga_egm08_25.tif`). `make_data.py` rebuilds the two PNG files from them; its docstring gives the
encoding and the commands.

## Preview locally

```
cd explorer
python -m http.server 8000
```

then open <http://localhost:8000/>. Opening `index.html` as a file does not work, because the page
fetches its data.
