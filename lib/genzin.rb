#!/usr/bin/env ruby
require 'fileutils'
require 'thor'
require 'xcodeproj'

def get_cell_name
  print 'Cell class name: '
  the_cell_name = STDIN.gets.chomp
  return the_cell_name
end

def get_script_path(path)
  return File.expand_path(File.dirname(__FILE__)) + path
end

def get_or_create_cells_folder(root)
  if File.exists?("#{root}/Views/Cells")
    return Dir["#{root}/Views/Cells"].first
  else
    puts "Coudn't find folder `#{root}/Views/Cells`, creating one now"
    FileUtils::mkdir_p "#{root}/Views/Cells"
    return Dir["#{root}/Views/Cells"].first
  end
end

def choose_target(project)
  case project.targets.size
  when 0
    puts 'No targets available'
    return
  when 1
    puts "Using target #{project.targets.first.name}"
    return project.targets.first
  else
    project.targets.each_with_index do |t, i|
      puts "[#{i+1}] #{t.name}"
    end
    puts 'Choose a target'
    return
    selected_index = gets.chomp.to_i
    return projects.targets[selected_index-1]
  end
end

def choose_project
  projects = Dir["./*.xcodeproj"]
  case projects.size
  when 0
    puts 'No projects found'
    return
  when 1
    return projects[0]
  else
    projects.each_with_index do |p, i|
      puts "[#{i+1}] #{p}"
    end
    puts 'Choose a project'
    selected_index = gets.chomp.to_i
    return projects[selected_index-1]
  end
end

class Genzin < Thor
  desc 'template OPTION', 'Options: base, cell, controller, reactor'
  long_desc <<-LONGDESC
  `genzin` will generate xcode templates for The Reactive Architecture.
  LONGDESC
  def template(option)
    case option
    when 'base'
    when 'cell'
      # Get a project in folder and open it
      project_path = choose_project()
      return if project_path.nil?
      project = Xcodeproj::Project.open(project_path)

      # Get a project target
      target = choose_target(project)
      return if target.nil?

      cell_name = get_cell_name()

      target_name = "#{target.name}"
      dir_cells = get_or_create_cells_folder(target_name)

      # Get or create xcode groups
      group_views = project.main_group[target_name]["Views"]
      unless group_views
        group_views = project.main_group[target_name].new_group('Views')
      end

      group_cells = group_views['Cells']
      unless group_cells
        group_cells = group_views.new_group('Cells')
        puts "Created new group #{target_name}/Views/Cells"
      end

      # Write files and add to groups
      cell_template_path = "#{dir_cells}/#{cell_name}.swift"
      cell_template = File.read(get_script_path('/templates/CellTemplate.swift'))
      new_cell_template = cell_template.gsub('___CELLNAME___', cell_name)
      out_cell_template = File.new(cell_template_path, 'w')
      out_cell_template.puts(new_cell_template)
      out_cell_template.close
      group_cells.new_file("Views/Cells/#{cell_name}.swift")

      cell_r_template_path = "#{dir_cells}/#{cell_name}Reactor.swift"
      cell_r_template = File.read(get_script_path('/templates/CellReactorTemplate.swift'))
      new_cell_r_template = cell_r_template.gsub('___CELLNAME___', cell_name)
      out_cell_r_template = File.new(cell_r_template_path, 'w')
      out_cell_r_template.puts(new_cell_r_template)
      out_cell_r_template.close
      group_cells.new_file("Views/Cells/#{cell_name}Reactor.swift")

      project.save
    else
    end
  end
end

Genzin.start(ARGV)
