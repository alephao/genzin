#!/usr/bin/env ruby
require 'fileutils'
require 'xcodeproj'
require_relative 'generic_generator'

class CellGenerator
  include GenericGenerator

  CELL_SNIPPET_REGEXP = /declaration:\n(.*\n)\ninitialization:\n(.*)\nconstraint:\n(.*\n)\nreactor:\n(.*\n)/m

  CELL_SNIPPET_PLACEHOLDERS = [
      {placeholder: '___NAME___', property_field: :name},
      {placeholder: '___TYPE___', property_field: :type},
      {placeholder: '___REACTORPROPERTY___', property_field: :attribute}
  ]

  CELL_SNIPPET_FILE = 'templates/CellSnippet.swift'

  CELL_PLACEHOLDERS = [
    '___PROPERTIES___',
    '___ADDSUBVIEW___',
    '___CONSTRAINTS___',
    '___BINDREACTOR___'
  ]

  # CELL REACTOR CONSTANTS
  CELL_REACTOR_SNIPPET_REGEXP = /protocoloutput:\n(.*)\ncelloutput:\n(.*)\ninitialization:\n(.*\n)/m

  CELL_REACTOR_SNIPPET_PLACEHOLDERS = [
      {placeholder: '___PROPERTYNAME___', property_field: :name},
      {placeholder: '___PROPERTYTYPE___', property_field: :rxbind},
      {placeholder: '___PROPERTYINITPLACEHOLDER___', property_field: :rxplaceholder}
  ]

  CELL_REACTOR_SNIPPET_FILE = 'templates/CellReactorSnippet.swift'

  CELL_REACTOR_PLACEHOLDERS = [
    '___PROTOCOLOUTPUTS___',
    '___OUTPUTS___',
    '___INIT___'
  ]

  def initialize(project, target)
    @project = project
    @target = target
  end

  def get_or_create_cells_folder
    if File.exists?("#{@target.name}/Views/Cells")
      return Dir["#{@target.name}/Views/Cells"].first
    else
      puts "Creating folder #{@target.name}/Views/Cells"
      FileUtils::mkdir_p "#{@target.name}/Views/Cells"
      return Dir["#{@target.name}/Views/Cells"].first
    end
  end

  def get_or_create_xcode_cells_group
    group_views = @project.main_group[@target.name]["Views"]
    unless group_views
      group_views = @project.main_group[@target.name].new_group('Views')
    end

    group_cells = group_views['Cells']
    unless group_cells
      group_cells = group_views.new_group('Cells')
      puts "Created new group #{@target.name}/Views/Cells"
    end

    return group_cells
  end

  def create_base_if_needed
    unless File.exists?("#{@target.name}/Views/Cells/BaseTableViewCell.swift")
      dir_cells = get_or_create_cells_folder
      group_cells = get_or_create_xcode_cells_group

      dir_base_cell = get_script_path('/genzin/templates/BaseTableViewCell.swift')
      FileUtils::cp(dir_base_cell, dir_cells)

      file_ref = group_cells.new_file('Views/Cells/BaseTableViewCell.swift')
      @target.add_resources([file_ref])

      puts 'Created BaseTableViewCell.swift'
    end
  end

  def new_cell
    print 'Cell class name: '
    cell_name = STDIN.gets.chomp

    dir_cells = get_or_create_cells_folder()
    group_cells = get_or_create_xcode_cells_group()

    create_base_if_needed()

    cell_properties = get_properties
    cell_snippets = get_snippets cell_properties, CELL_SNIPPET_FILE, CELL_SNIPPET_REGEXP, CELL_SNIPPET_PLACEHOLDERS

    cell_template_path = "#{dir_cells}/#{cell_name}.swift"
    cell_template = File.read(get_script_path('/genzin/templates/CellTemplate.swift'))
    new_cell_template = cell_template.gsub('___CELLNAME___', cell_name)
    CELL_PLACEHOLDERS.each_with_index do |cp, i|
      new_cell_template.gsub!(cp, cell_snippets[i])
    end
    out_cell_template = File.new(cell_template_path, 'w')
    out_cell_template.puts(new_cell_template)
    out_cell_template.close
    cell_fileref = group_cells.new_file("Views/Cells/#{cell_name}.swift")
    puts "Created #{cell_name}.swift"

    cell_reactor_snippets = get_snippets cell_properties, CELL_REACTOR_SNIPPET_FILE, CELL_REACTOR_SNIPPET_REGEXP, CELL_REACTOR_SNIPPET_PLACEHOLDERS

    cell_r_template_path = "#{dir_cells}/#{cell_name}Reactor.swift"
    cell_r_template = File.read(get_script_path('/genzin/templates/CellReactorTemplate.swift'))
    new_cell_r_template = cell_r_template.gsub('___CELLNAME___', cell_name)
    CELL_REACTOR_PLACEHOLDERS.each_with_index do |cp, i|
      new_cell_r_template.gsub!(cp, cell_reactor_snippets[i])
    end
    out_cell_r_template = File.new(cell_r_template_path, 'w')
    out_cell_r_template.puts(new_cell_r_template)
    out_cell_r_template.close
    cell_r_fileref = group_cells.new_file("Views/Cells/#{cell_name}Reactor.swift")
    puts "Created #{cell_name}Reactor.swift"

    @target.add_resources([cell_fileref, cell_r_fileref])
  end
end
