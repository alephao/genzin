#!/usr/bin/env ruby
require 'fileutils'
require 'xcodeproj'
require_relative 'view_generator'

module Genzin
  # This class is used to generate Controllers and its ViewModels
  #
  class ControllerGenerator

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

    # Create the View/Controllers folder if needed
    #
    # @return [String] the View/Controllers path
    #
    def get_or_create_controllers_folder
      unless File.exists?("#{@target.name}/Views/Controllers")
        puts "Creating folder #{@target.name}/Views/Controllers"
        FileUtils::mkdir_p "#{@target.name}/Views/Controllers"
      end
      Dir["#{@target.name}/Views/Controllers"].first
    end


    # Create the View/Controllers group if needed
    #
    # @return [PBXGroup] the View/Controllers group
    #
    def get_or_create_xcode_controllers_group
      group_views = @project.main_group[@target.name]['Views']
      unless group_views
        group_views = @project.main_group[@target.name].new_group('Views')
      end

      group_controllers = group_views['Controllers']
      unless group_controllers
        group_controllers = group_views.new_group('Controllers')
        puts "Created new group #{@target.name}/Views/Controllers"
      end

      group_controllers
    end

    # Copy the BaseViewController.swift to the View/Controllers
    # directory if needed and create a Xcode Group if needed
    #
    def create_base_if_needed
      unless File.exists?("#{@target.name}/Views/Controllers/BaseViewController.swift")
        dir_controllers = get_or_create_controllers_folder
        group_controllers = get_or_create_xcode_controllers_group

        dir_base_controller = GenzinHelper.get_script_path('/genzin/templates/BaseViewController.swift')
        FileUtils::cp(dir_base_controller, dir_controllers)

        file_ref = group_controllers.new_file('Views/Controllers/BaseViewController.swift')
        @target.add_file_references([file_ref])

        puts 'Created BaseViewController.swift'
      end
    end

    # Create controller snippets to sub on template
    #
    # @param [Array<UIKitProperty>] properties
    #
    # @return [Hash{String => String}] the placeholder -> snippet map
    #
    def create_controller_snippets(properties)
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

    # Create controller ViewModel snippets to sub on template
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

    # Generates a new controller
    #
    # @note Asks user for the Controller name and its Properties
    #
    def new_controller
      print 'Controller class name: '
      controller_name = STDIN.gets.chomp

      dir_controllers = get_or_create_controllers_folder
      group_controllers = get_or_create_xcode_controllers_group

      create_base_if_needed

      controller_properties = @view_generator.get_properties
      controller_snippets = create_controller_snippets controller_properties

      controller_fileref = @view_generator.write_template"#{TEMPLATE_PATH}ControllerTemplate.swift",
                                                         "#{controller_name}ViewController.swift",
                                                         dir_controllers,
                                                         group_controllers,
                                                         {'___CONTROLLERNAME___' => "#{controller_name}"},
                                                         controller_snippets

      controller_viewmodel_snippets = create_viewmodel_snippets controller_properties
      controller_r_fileref = @view_generator.write_template"#{TEMPLATE_PATH}ControllerViewModelTemplate.swift",
                                                           "#{controller_name}ViewModel.swift",
                                                           dir_controllers,
                                                           group_controllers,
                                                           { '___CONTROLLERNAME___' => controller_name },
                                                           controller_viewmodel_snippets

      @target.add_file_references([controller_fileref, controller_r_fileref])
    end
  end
end
