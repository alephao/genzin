#!/usr/bin/env ruby
require 'fileutils'
require 'xcodeproj'

class CellGenerator
  VALID_PROPERTIES = {
      label:     { suffix: 'Label',     type: 'Label', reactor_property: 'text'},
      imageview: { suffix: 'ImageView', type: 'Image', reactor_property: 'image'}
  }

  SNIPPET_REGEXP = /declaration:\n(.*\n)\ninitialization:\n(.*\n)\nconstraint:\n(.*\n)\nreactor:\n(.*\n)/m

  SNIPPET_PLACEHOLDERS = [
      {placeholder: '___NAME___', property_field: :name},
      {placeholder: '___TYPE___', property_field: :type},
      {placeholder: '___REACTORPROPERTY___', property_field: :reactor_property}
  ]

  SNIPPET_FILE = 'templates/CellSnippet.swift'

  def initialize(project, target)
    @project = project
    @target_name = target.name
  end

  def get_or_create_cells_folder
    if File.exists?("#{@target_name}/Views/Cells")
      return Dir["#{@target_name}/Views/Cells"].first
    else
      puts "Creating folder #{@target_name}/Views/Cells"
      FileUtils::mkdir_p "#{@target_name}/Views/Cells"
      return Dir["#{@target_name}/Views/Cells"].first
    end
  end

  def get_or_create_xcode_cells_group
    group_views = @project.main_group[@target_name]["Views"]
    unless group_views
      group_views = @project.main_group[@target_name].new_group('Views')
    end

    group_cells = group_views['Cells']
    unless group_cells
      group_cells = group_views.new_group('Cells')
      puts "Created new group #{@target_name}/Views/Cells"
    end

    return group_cells
  end

  def create_base_if_needed
    unless File.exists?("#{@target_name}/Views/Cells/BaseTableViewCell.swift")
      dir_cells = get_or_create_cells_folder
      group_cells = get_or_create_xcode_cells_group

      dir_base_cell = get_script_path('/genzin/templates/BaseTableViewCell.swift')
      FileUtils::cp(dir_base_cell, dir_cells)

      group_cells.new_file('View/Cells/BaseTableViewCell.swift')

      puts 'Created BaseTableViewCell.swift'
    end
  end

  def get_properties
    regex = Regexp.new('(' + VALID_PROPERTIES.keys.join('|') + ')$', true)
    properties = []
    while true
      print "\nProperty name (empty to quit): "
      property_name = STDIN.gets.chomp.strip
      return properties if property_name.empty?
      m = regex.match(property_name)
      if m.nil?
        puts "\nInvalid property name: #{property_name}"
      else
        puts m[1]
        prop = VALID_PROPERTIES[m[1].downcase.to_sym]
        properties << {name: property_name.gsub(regex, prop[:suffix]), type: prop[:type], reactor_property: prop[:reactor_property]}
      end
    end
  end

  def code_properties(properties)
    code = ''
    script_file = File.dirname(File.expand_path(__FILE__))
    snippet_file = File.expand_path(script_file + '/' + SNIPPET_FILE)
    puts snippet_file
    if File.exists?(snippet_file)
      snippet = File.read(snippet_file)
      m = snippet.match(SNIPPET_REGEXP)
      unless m.nil?
        sections = Array.new(m.length-1, '')
        properties.each do |prop|
          (1..m.length-1).each do |s|
            section_code = m[s]
            SNIPPET_PLACEHOLDERS.each do |ph|
              section_code.gsub!(ph[:placeholder], prop[ph[:property_field]])
            end
            sections[s-1] += section_code + "\n"
          end
        end
        code = sections.join("\n")
      end
    end
    code
  end

  def new_cell
    print 'Cell class name: '
    cell_name = STDIN.gets.chomp

    dir_cells = get_or_create_cells_folder
    group_cells = get_or_create_xcode_cells_group

    create_base_if_needed

    properties = get_properties
    puts properties

    cp = code_properties properties
    puts cp

    # cell_template_path = "#{dir_cells}/#{cell_name}.swift"
    # cell_template = File.read(get_script_path('/genzin/templates/CellTemplate.swift'))
    # new_cell_template = cell_template.gsub('___CELLNAME___', cell_name)
    # out_cell_template = File.new(cell_template_path, 'w')
    # out_cell_template.puts(new_cell_template)
    # out_cell_template.close
    # group_cells.new_file("Views/Cells/#{cell_name}.swift")
    # puts "Created #{cell_name}.swift"
    #
    # cell_r_template_path = "#{dir_cells}/#{cell_name}Reactor.swift"
    # cell_r_template = File.read(get_script_path('/genzin/templates/CellReactorTemplate.swift'))
    # new_cell_r_template = cell_r_template.gsub('___CELLNAME___', cell_name)
    # out_cell_r_template = File.new(cell_r_template_path, 'w')
    # out_cell_r_template.puts(new_cell_r_template)
    # out_cell_r_template.close
    # group_cells.new_file("Views/Cells/#{cell_name}Reactor.swift")
    # puts "Created #{cell_name}Reactor.swift"
  end
end
