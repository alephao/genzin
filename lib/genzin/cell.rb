#!/usr/bin/env ruby
require 'fileutils'
require 'xcodeproj'
require_relative 'view_generator'

# This class is used to generate Cells and its ViewModels
#
class CellGenerator
  include ViewGenerator

  # CELL CONSTANTS
  CELL_SNIPPET_REGEXP = /declaration:\n(.*\n)\ninitialization:\n(.*)\nconstraint:\n(.*\n)\nviewmodel:\n(.*\n)/m

  CELL_SNIPPET_PLACEHOLDERS = [
      {placeholder: '___NAME___', property_field: :name},
      {placeholder: '___TYPE___', property_field: :type},
      {placeholder: '___VIEWMODELPROPERTY___', property_field: :attribute}
  ]

  CELL_SNIPPET_FILE = 'templates/CellSnippet.swift'

  CELL_PLACEHOLDERS = [
    '___PROPERTIES___',
    '___ADDSUBVIEW___',
    '___CONSTRAINTS___',
    '___BINDVIEWMODEL___'
  ]

  # CELL VIEWMODEL CONSTANTS
  CELL_VIEWMODEL_SNIPPET_REGEXP = /protocoloutput:\n(.*)\ncelloutput:\n(.*)\ninitialization:\n(.*\n)/m

  CELL_VIEWMODEL_SNIPPET_PLACEHOLDERS = [
      {placeholder: '___PROPERTYNAME___', property_field: :name},
      {placeholder: '___PROPERTYTYPE___', property_field: :rxbind},
      {placeholder: '___PROPERTYINITPLACEHOLDER___', property_field: :rxplaceholder}
  ]

  CELL_VIEWMODEL_SNIPPET_FILE = 'templates/CellViewModelSnippet.swift'

  CELL_VIEWMODEL_PLACEHOLDERS = [
    '___PROTOCOLOUTPUTS___',
    '___OUTPUTS___',
    '___INIT___'
  ]

  # @param [Project] project
  #        The Xcode project you want to modify
  # @param [AbstractTarget] target
  #        The project target you want to modify
  #
  def initialize(project, target)
    @project = project
    @target = target
  end

  # Create the View/Cells folder if needed
  #
  # @return [String] the View/Cells path
  #
  def get_or_create_cells_folder
    unless File.exists?("#{@target.name}/Views/Cells")
      puts "Creating folder #{@target.name}/Views/Cells"
      FileUtils::mkdir_p "#{@target.name}/Views/Cells"
    end
    Dir["#{@target.name}/Views/Cells"].first
  end


  # Create the View/Cells group if needed
  #
  # @return [PBXGroup] the View/Cells group
  #
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

    group_cells
  end

  # Copy the BaseTableViewCell.swift to the View/Cells
  # directory if needed and create a Xcode Group if needed
  #
  def create_base_if_needed
    unless File.exists?("#{@target.name}/Views/Cells/BaseTableViewCell.swift")
      dir_cells = get_or_create_cells_folder
      group_cells = get_or_create_xcode_cells_group

      dir_base_cell = get_script_path('/genzin/templates/BaseTableViewCell.swift')
      FileUtils::cp(dir_base_cell, dir_cells)

      file_ref = group_cells.new_file('Views/Cells/BaseTableViewCell.swift')
      @target.add_file_references([file_ref])

      puts 'Created BaseTableViewCell.swift'
    end
  end

  # Generates a new cell
  #
  # @note Asks user for the Cell name and its Properties
  #
  def new_cell
    print 'Cell class name: '
    cell_name = STDIN.gets.chomp
    cell_viewmodel_name = cell_name + "ViewModel"

    dir_cells = get_or_create_cells_folder
    group_cells = get_or_create_xcode_cells_group

    create_base_if_needed

    cell_properties = get_properties
    cell_snippets = get_snippets cell_properties, CELL_SNIPPET_FILE, CELL_SNIPPET_REGEXP, CELL_SNIPPET_PLACEHOLDERS

    cell_fileref = write_template("#{TEMPLATE_PATH}CellTemplate.swift",
                                  dir_cells,
                                  group_cells,
                                  '___CELLNAME___',
                                  cell_name,
                                  CELL_PLACEHOLDERS,
                                  cell_snippets)

    cell_viewmodel_snippets = get_snippets cell_properties, CELL_VIEWMODEL_SNIPPET_FILE, CELL_VIEWMODEL_SNIPPET_REGEXP, CELL_VIEWMODEL_SNIPPET_PLACEHOLDERS
    cell_r_fileref = write_template("#{TEMPLATE_PATH}CellViewModelTemplate.swift",
                                    dir_cells,
                                    group_cells,
                                    '___CELLNAME___',
                                    cell_viewmodel_name,
                                    CELL_VIEWMODEL_PLACEHOLDERS,
                                    cell_viewmodel_snippets)

    @target.add_file_references([cell_fileref, cell_r_fileref])
  end
end
