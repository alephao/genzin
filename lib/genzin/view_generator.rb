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
    # @param [String] target_dir
    #        The folder to generate the file in
    # @param [PBXGroup] group
    #        The Xcode group to put the file in
    # @param [String] main_placeholder
    #        The placeholder for main_name (next param)
    # @param [String] main_name
    #        The class name (eg. ExampleViewController)
    # @param [Array<String>] snippets
    #        The snippets to sub the placeholders
    #
    # @return [PBXFileReference] the new file
    #
    # @note The 'placeholders' and 'snippets' must be in the same order!
    #
    def write_template(template_file, target_dir, group, main_placeholder, main_name, snippets)
      template = File.read(GenzinHelper.get_script_path(template_file))
      new_code = template.gsub(main_placeholder, main_name)
      snippets.each do |placeholder, snippet|
        new_code.gsub!(placeholder, snippet || '')
      end
      new_file = "#{target_dir}/#{main_name}.swift"
      out_cell_template = File.new(new_file, 'w')
      out_cell_template.puts(new_code)
      out_cell_template.close
      puts "Created #{main_name}.swift"
      group.new_file("Views/Cells/#{main_name}.swift")
    end
  end
end
