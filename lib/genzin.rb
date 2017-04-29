#!/usr/bin/env ruby
require 'fileutils'
require 'thor'
require 'xcodeproj'
require_relative 'genzin/cell'

module Genzin
  TEMPLATE_PATH = '/genzin/templates/'

  class GenzinHelper
    def self.get_script_path(path)
      return File.expand_path(File.dirname(__FILE__)) + path
    end

    def self.choose_target(project)
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
          selected_index = STDIN.gets.chomp.to_i
          return project.targets[selected_index-1]
      end
    end

    def self.choose_project
      projects = Dir['./*.xcodeproj']
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
          selected_index = STDIN.gets.chomp.to_i
          return projects[selected_index-1]
      end
    end
  end

  class CLI < Thor
    desc 'cell [OPTIONS]','options: --no-viewmodel --no-properties'
    def cell
      # Get a project in folder and open it
      project_path = GenzinHelper.choose_project
      return if project_path.nil?
      project = Xcodeproj::Project.open project_path

      # Get a project target
      target = GenzinHelper.choose_target project
      return if target.nil?

      cell_generator = CellGenerator.new project, target
      cell_generator.new_cell

      project.save
    end
  end
end