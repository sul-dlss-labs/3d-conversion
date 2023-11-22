# 3D Conversion

This repository contains some code used for converting 3d object files from [OBJ] format to [glTF] files. The reason for doing this was that [sul-embed](https://github.com/sul-dlss/sul-embed) had been using [virtex3d] for viewing the OBJ files, and it is no longer being maintained. [model-viewer] was selected as a replacement, but it only works with glTF files. So we need to update SDR 3D objects to include a `glb` file, which is the compressed binary version of glTF files. 

Argo was used to create a report of 3D objects that have been accessioned, and then save the druids as text file `druids.txt`. This file was used to export the objects using [SDRGET], and the data was transfered to the `bags` directory with rsync. Additionally an Argo Batch Job was used to export the structural metadata for the same set of 3D items, which was saved as `structural.csv`.

Once `bags` was transferred and the bags were validated the following commands were run:

```
$ yarn install
$ ./convert.rb
```

This installs the [obj2gltf] conversion program and then uses it create a set of new files in the `output` directory.

## Conversion Errors

When running the conversion in November 2023 the following errors were encountered:

### Missing obj files

* hc941fm6529 lacked an OBJ file, which wasn't fixable.
 
### Missing texture files

The obj file often references a material file (.mtl) which references texture files (.jpg). In some cases the referenced texture files were just missing. The missing texture files didn't prevent a GLB file from being created, and didn't result in a degradation in viewing since it was a problem with the OBJ file as well.

* ng589kj1631 was lacking: white_limestone2.jpg, White_Plaster_Transparent.jpg, white_mudplaster.jpg, White_Plaster_Transparent_Transparent.jpg, pink_granite2.jpg, white_limeston_block.jpg, White_Plaster_Transparent_Transparent1.jpg, white_mudplaster1.jpg, mudplaster1.jpg
* rj811bj9781 was lacking Emery1961_3035.jpg

### Misnamed MTL files

There were also some `.obj` files that referenced material files incorrectly (.mtl):

* Could not read material file at bags/cb462jn0451/data/content/Huynefer&Nebnefer_ST217.mtl
* Could not read material file at bags/fh129xw6834/data/content/Pay&Raia.mtl
* Could not read material file at bags/fp375qc0402/data/content/Nebnefer&Mahu_ST218.mtl
* Could not read material file at bags/sz524fd9637/data/content/Ra'ia.mtl
* Could not read material file at bags/tx237xp2328/data/content/Rest House.mtl
* Could not read material file at bags/vg134yk1706/data/content/Maya&Meryt.mtl

Since there didn't seem to be a reliable pattern for these errors the .obj files, and the files were present, the .obj files were manually updated to point to the correct .mtl file. These 

[OBJ]: https://en.wikipedia.org/wiki/Wavefront_.obj_file
[glTF]: https://en.wikipedia.org/wiki/GlTF
[virtex3d]: https://github.com/edsilv/virtex
[model-viewer]: https://modelviewer.dev/
[SDRGET]: https://consul.stanford.edu/pages/viewpage.action?pageId=1646529897
