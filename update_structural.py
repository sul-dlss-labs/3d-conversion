import re
import pandas

df = pandas.read_csv('structural.csv')
df = df.sort_values(['druid', 'sequence'])

# this one didn't convert so it can be removed from the file_manifest
df = df[df['druid'] != 'hc941fm6529']

# there are two files marked as 3d which aren't .obj files
df.loc[(df.resource_type == '3d') ^ (df.filename.str.endswith('.obj')), 'resource_type'] = 'file'

# this one zip had a different resource type from all the rest of the zips
df.loc[df.filename == 'bc769sr4504.zip', 'resource_type'] = 'file'

# get a copy of all the existing .obj 3d objects so we can modify and add them back as glb files
glbs = df[df.resource_type == '3d'].copy()

# now we can update all the original 3d objects to be type file
df.loc[df.resource_type == '3d', 'resource_type'] = 'file'

# update the original obj files to make them into glb files
glbs.filename = glbs.filename.str.replace(r'\.obj$', '.glb', regex=True)
glbs.file_label = glbs.file_label.str.replace(r'\.obj$', '.glb', regex=True)
glbs.mimetype = 'model/gltf-binary'

# this complicated function takes each new glb row and modifies its sequence and
# resource label.
def update_sequences(row):
    row.sequence = df[df.druid == row.druid].sequence.max() + 1
    if row.resource_label == 'Object 1':
        row.resource_label = 'Object 2'
    elif row.resource_label == '3d 1':
        row.resource_label = '3d 2'
    elif m := re.match(r'File (\d+)', row.resource_label):
        max_seq = df[df.druid == row.druid].sequence.max()
        row.resource_label = row.resource_label.replace(m.group(1), str(max_seq + 1))
    else:
        raise Exception(f"unknown 3d resource label: {row}")
    return row

glbs = glbs.apply(update_sequences, axis=1)

# add our new glb files to the original table
df = pandas.concat([df, glbs])

# sort by druid and sequence so that the new glb files appear alongside the other druid files
df = df.sort_values(['druid', 'sequence'])

# export it!
df.to_csv('output/file_manifest.csv', index=False)
