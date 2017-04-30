#!/usr/bin/env ruby
require_relative 'swift_property'

module Genzin
  class ViewGenerator
    VALID_PROPERTIES = {
        imageview: {
            suffix: 'ImageView',
            type: 'UIImageView'
        },
        label:     {
            suffix: 'Label',
            type: 'UILabel'
        },
        textfield: {
            suffix: 'TextField',
            type: 'UITextField'
        }
    }

    # Get a property name and check if it is a valid property
    #
    # @param [String] prompt
    #
    # @return [Array<UIKitProperty>]
    #
    def get_properties(prompt='property name')
      regex = Regexp.new('(' + VALID_PROPERTIES.keys.join('|') + ')$', true)
      properties = []
      while true
        print "\n#{prompt.capitalize} (empty to quit): "
        property_name = STDIN.gets.chomp.strip
        if property_name.empty?
          return properties
        end
        m = regex.match(property_name)
        if m.nil?
          puts "\nInvalid #{prompt}: #{property_name}"
        else
          prop = VALID_PROPERTIES[m[1].downcase.to_sym]
          properties << UIKitProperty.new(property_name.gsub(prop[:suffix], ''),
                                          prop[:suffix],
                                          prop[:type])
        end
      end
    end

    # Generate a new file from a template and the snippets
    # and add it to a Xcode group
    #
    # @param [String] template_file
    #        The template path relative to the lib folder
    # @param [String] file_name
    #        The file name
    # @param [String] target_dir
    #        The folder to generate the file in
    # @param [PBXGroup] group
    #        The Xcode group to put the file in
    # @param [Hash{String => String}] placeholder_map
    #        The Placeholder => String map (if needed)
    # @param [Array<String>] snippets
    #        The snippets to sub the placeholders
    #
    # @return [PBXFileReference] the new file
    #
    # @note The 'placeholders' and 'snippets' must be in the same order!
    #
    def write_template(template_file, file_name, target_dir, group, placeholder_map, snippets)
      template = File.read(GenzinHelper.get_script_path(template_file))
      new_code = template
      if placeholder_map
        placeholder_map.each do |placeholder, value|
          template.gsub!(placeholder, value)
        end
      end
      snippets.each do |placeholder, snippet|
        new_code.gsub!(placeholder, snippet || '')
      end
      new_file = "#{target_dir}/#{file_name}"
      out_cell_template = File.new(new_file, 'w')
      out_cell_template.puts(new_code)
      out_cell_template.close
      puts "Created #{file_name}"
      group_path = target_dir[((target_dir.index '/')+1)..target_dir.size] # Get the path without the root (a/b/c/d becomes b/c/d)
      group.new_file("#{group_path}/#{file_name}")
    end
  end
end
