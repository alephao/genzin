#!/usr/bin/env ruby
require 'fileutils'
require 'xcodeproj'
require_relative 'view_generator'

module Genzin
  # This class is used to generate Cells and its ViewModels
  #
  class CellGenerator

    # @param [Project] project
    #        The Xcode project you want to modify
    # @param [AbstractTarget] target
    #        The project target you want to modify
    #
    def initialize(project, target)
      @project = project
      @target = target

      @view_generator = ViewGenerator.new
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
      group_views = @project.main_group[@target.name]['Views']
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

        dir_base_cell = GenzinHelper.get_script_path('/genzin/templates/BaseTableViewCell.swift')
        FileUtils::cp(dir_base_cell, dir_cells)

        file_ref = group_cells.new_file('Views/Cells/BaseTableViewCell.swift')
        @target.add_file_references([file_ref])

        puts 'Created BaseTableViewCell.swift'
      end
    end

    # Create cell snippets to sub on template
    #
    # @param [Array<UIKitProperty>] properties
    #
    # @return [Hash{String => String}] the placeholder -> snippet map
    #
    def create_cell_snippets(properties)
      declarations = []
      add_subviews = []
      make_constraints = []
      bind_inputs = []
      bind_outputs = []
      properties.each do |p|
        declarations << p.declaration
        add_subviews << p.add_subview(false)
        make_constraints << p.make_constraints
        bind_inputs.concat p.bind_inputs
        bind_outputs.concat p.bind_outputs
      end

      properties_snippet = declarations.sort.reduce { |t, s| "#{t}\n#{s}" }
      add_subviews_snippet = add_subviews.sort.reduce { |t, s| "#{t}\n#{s}" }
      constraints_snippet = make_constraints.sort.reduce { |t, s| "#{t}\n#{s}" }
      bind_inputs_snippet = bind_inputs.sort.reduce { |t, s| "#{t}\n#{s}" }
      bind_outputs_snippet = bind_outputs.sort.reduce { |t, s| "#{t}\n#{s}" }

      {
          '___PROPERTIES___' => properties_snippet,
          '___ADDSUBVIEW___' => add_subviews_snippet,
          '___CONSTRAINTS___' => constraints_snippet,
          '___BINDVIEWMODELINPUTS___' => bind_inputs_snippet,
          '___BINDVIEWMODELOUTPUTS___' => bind_outputs_snippet,
      }
    end

    # Create cell ViewModel snippets to sub on template
    #
    # @param [Array<UIKitProperty>] properties
    #
    # @return [Hash{String => String}] the placeholder -> snippet map
    #
    def create_viewmodel_snippets(properties)
      protocol_inputs = []
      protocol_outputs = []
      viewmodel_inputs_declarations = []
      viewmodel_outputs_declarations = []
      viewmodel_outputs_inits = []
      properties.each do |p|
        protocol_inputs.concat p.protocol_inputs
        protocol_outputs.concat p.protocol_outputs
        viewmodel_inputs_declarations.concat p.viewmodel_inputs_declaration
        viewmodel_outputs_declarations.concat p.viewmodel_outputs_declaration
        viewmodel_outputs_inits.concat p.viewmodel_outputs_init
      end

      protocol_inputs_snippet = protocol_inputs.sort.reduce { |t, s| "#{t}\n#{s}" }
      protocol_outputs_snippet = protocol_outputs.sort.reduce { |t, s| "#{t}\n#{s}" }
      viewmodel_inputs_declarations_snippet = viewmodel_inputs_declarations.sort.reduce { |t, s| "#{t}\n#{s}" }
      viewmodel_outputs_declarations_snippet = viewmodel_outputs_declarations.sort.reduce { |t, s| "#{t}\n#{s}" }
      viewmodel_outputs_inits_snippet = viewmodel_outputs_inits.sort.reduce { |t, s| "#{t}\n#{s}" }

      {
          '___PROTOCOLINTPUTS___' => protocol_inputs_snippet,
          '___PROTOCOLOUTPUTS___' => protocol_outputs_snippet,
          '___INPUTS___' => viewmodel_inputs_declarations_snippet,
          '___OUTPUTS___' => viewmodel_outputs_declarations_snippet,
          '___INIT___' => viewmodel_outputs_inits_snippet,
      }
    end

    # Generates a new cell
    #
    # @note Asks user for the Cell name and its Properties
    #
    def new_cell
      print 'Cell class name: '
      cell_name = STDIN.gets.chomp
      cell_viewmodel_name = "#{cell_name}ViewModel"

      dir_cells = get_or_create_cells_folder
      group_cells = get_or_create_xcode_cells_group

      create_base_if_needed

      cell_properties = @view_generator.get_properties
      cell_snippets = create_cell_snippets cell_properties

      cell_fileref = @view_generator.write_template"#{TEMPLATE_PATH}CellTemplate.swift",
                                                   dir_cells,
                                                   group_cells,
                                                   '___CELLNAME___',
                                                   cell_name,
                                                   cell_snippets

      cell_viewmodel_snippets = create_viewmodel_snippets cell_properties
      cell_r_fileref = @view_generator.write_template"#{TEMPLATE_PATH}CellViewModelTemplate.swift",
                                                               dir_cells,
                                                               group_cells,
                                                               '___CELLNAME___',
                                                               cell_viewmodel_name,
                                                               cell_viewmodel_snippets

      @target.add_file_references([cell_fileref, cell_r_fileref])
    end
  end
end
