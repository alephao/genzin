#!/usr/bin/env ruby
require 'thor'
require 'xcodeproj'

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
    selectedIndex = gets.chomp.to_i
    return projects.targets[selectedIndex-1]
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
    selectedIndex = gets.chomp.to_i
    return projects[selectedIndex-1]
  end
end

class Genzin < Thor
  desc 'template OPTION', 'Options: base, cell, controller, reactor'
  long_desc <<-LONGDESC
  `genzin` will generate xcode templates for The Reactive Architecture.
  LONGDESC
  def template(option)
    case option
    when 'cell'
      project_path = choose_project()
      return if project_path.nil?

      project = Xcodeproj::Project.open(project_path)
      choose_target(project)
    else
    end
  end
end

Genzin.start(ARGV)
