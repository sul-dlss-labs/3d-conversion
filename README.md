# 3D Conversion

This repository contains some code for converting 3d object files from [OBJ] format to [glTF] files. The reason for doing this was that [sul-embed](https://github.com/sul-dlss/sul-embed) had been using ([virtex3d]) for viewing the OBJ files, and is no longer being maintained. The viewer that was selected to move to ([model-viewer]) only works with glTF files. We are specifically going to be converting to `glb`, which is the compressed binary version of glTF files. 

To convert the SDR 3D objects Argo was used to create a report of 3d objects that have been accessioned, and then save the druids as text file `druids.txt`. Then to export the objects using [SDRGET] and transfer the data here to the `bags` directory.

In addition an Argo Batch Job was used to export the structural metadata for the same set of 3D items, and saved as `structural.csv`.

Once `bags` was transferred and the bags were validated the following commands was run:

```
$ yarn install
$ ./convert.rb
```

This installs the [obj2gltf] conversion program and then uses it create a set of new files in the `output` directory.


## Conversion Errors

When running the conversion in November, 2023 the following errors were encountered:

* hc941fm6529 lacked an OBJ file
* ng589kj1631 was lacking some texture files: white_limestone2.jpg, White_Plaster_Transparent.jpg, white_mudplaster.jpg, White_Plaster_Transparent_Transparent.jpg, pink_granite2.jpg, white_limeston_block.jpg, White_Plaster_Transparent_Transparent1.jpg, white_mudplaster1.jpg, mudplaster1.jpg
* rj811bj9781 was lacking a texture file: Emery1961_3035.jpg

The missing texture files didn't prevent a GLB file from being created, and didn't result in a degradation in viewing since it was a problem with the OBJ file as well.

[OBJ]: https://en.wikipedia.org/wiki/Wavefront_.obj_file
[glTF]: https://en.wikipedia.org/wiki/GlTF
[virtex3d]: https://github.com/edsilv/virtex
[model-viewer]: https://modelviewer.dev/
[SDRGET]: https://consul.stanford.edu/pages/viewpage.action?pageId=1646529897
