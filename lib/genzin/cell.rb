#!/usr/bin/env ruby
require 'fileutils'
require 'xcodeproj'

class CellGenerator
  def initialize(project, target)
    @project = project
    @target_name = target.name
  end

  def get_or_create_cells_folder
    if File.exists?("#{@target_name}/Views/Cells")
      return Dir["#{@target_name}/Views/Cells"].first
    else
      puts "Coudn't find folder `#{@target_name}/Views/Cells`, creating one now"
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

  def new_cell
    print 'Cell class name: '
    cell_name = STDIN.gets.chomp

    dir_cells = get_or_create_cells_folder
    group_cells = get_or_create_xcode_cells_group

    cell_template_path = "#{dir_cells}/#{cell_name}.swift"
    cell_template = File.read(get_script_path('/genzin/templates/CellTemplate.swift'))
    new_cell_template = cell_template.gsub('___CELLNAME___', cell_name)
    out_cell_template = File.new(cell_template_path, 'w')
    out_cell_template.puts(new_cell_template)
    out_cell_template.close
    group_cells.new_file("Views/Cells/#{cell_name}.swift")

    cell_r_template_path = "#{dir_cells}/#{cell_name}Reactor.swift"
    cell_r_template = File.read(get_script_path('/genzin/templates/CellReactorTemplate.swift'))
    new_cell_r_template = cell_r_template.gsub('___CELLNAME___', cell_name)
    out_cell_r_template = File.new(cell_r_template_path, 'w')
    out_cell_r_template.puts(new_cell_r_template)
    out_cell_r_template.close
    group_cells.new_file("Views/Cells/#{cell_name}Reactor.swift")
  end
end
