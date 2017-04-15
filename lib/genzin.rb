#!/usr/bin/env ruby
require 'fileutils'
require 'thor'
require 'xcodeproj'
require_relative 'genzin/cell'

def get_script_path(path)
  return File.expand_path(File.dirname(__FILE__)) + path
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

      cell_generator = CellGenerator.new(project, target)
      cell_generator.new_cell()

      project.save
    else
    end
  end
end

Genzin.start(ARGV)
