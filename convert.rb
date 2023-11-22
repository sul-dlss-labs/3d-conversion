#!/usr/bin/env ruby

require 'open3'
require 'logger'
require 'pathname'

def main
  obj_converter = ObjConverter.new
  File.readlines('druids.txt', chomp: true).each do |druid|
    # find the .obj file for the druid
    obj_file = find_obj_file(druid)
    unless obj_file
      puts "missing .obj file for #{druid}"
      next
    end

    # determine the path to write the glb to
    glb_file = make_glb_path(druid, obj_file)

    # run the conversion!
    obj_converter.convert(obj_file, glb_file)
  end
end

# find the obj file by druid in the bags
def find_obj_file(druid)
  dir = Pathname.new('bags') + "#{druid}/data/content"
  dir = dir.expand_path
  obj_file = dir.entries.find { |path| path.extname == '.obj' }
  obj_file ? dir + obj_file : nil
end

# construct the path to write the glb file to
def make_glb_path(druid, obj_file)
  glb_file = Pathname.new('output') + druid + obj_file.basename.sub_ext('.glb')
  glb_file.expand_path
end

# Convert an OBJ file to GLTF
class ObjConverter
  def initialize
    @log = Logger.new('convert.log')
    @obj2gltf = Pathname('node_modules/.bin/obj2gltf').expand_path
    raise 'obj2gltf is not installed' unless @obj2gltf.file?
  end

  def convert(obj_file, glb_file)
    run_obj2gltf(obj_file, glb_file)
  end

  private

  def run_obj2gltf(obj_file, glb_file, patch_obj: true)
    @log.info("converting #{obj_file} to #{glb_file}")
    glb_file.dirname.mkpath unless glb_file.dirname.directory?

    cmd = "#{@obj2gltf} -i #{obj_file} -o #{glb_file}"
    stdout, _stderr, status = Open3.capture3(cmd)

    # index out of bound errors can be fixed
    if stdout =~ /Normal index \d+ is out of bounds/
      if patch_obj
        run_patched(obj_file, glb_file)
      else
        logging.error("not trying to patch #{obj_file}")
      end
    elsif status.exitstatus != 0
      @log.error("conversion error: #{stdout.gsub("\n", ' ')}")
    elsif !stdout.start_with?('Total:')
      @log.error("unexpected output: #{stdout.gsub("\n", ' ')}")
    end
  end

  # Create a copy of the original .obj file, and edit "nan" to "0.0" in the obj
  # file so obj2gltf doesn't complain. Then use that to convert to glb.
  # https://github.com/CesiumGS/obj2gltf/issues/243
  def run_patched(obj_file, glb_file)
    @log.info("patching #{obj_file} to replace nan values with 0.0")
    obj = obj_file.read
    patched = obj.gsub(/vn -nan\(ind\) -nan\(ind\) -nan\(ind\)/m, 'vn -0.0 -0.0 -0.0')
    patched_file = obj_file.sub_ext('.obj.patched')
    patched_file.write(patched)
    run_obj2gltf(patched_file, glb_file, patch_obj: false)
    patched_file.delete
  end
end

main if __FILE__ == $PROGRAM_NAME
