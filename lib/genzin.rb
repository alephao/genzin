#!/usr/bin/env ruby
require 'fileutils'
require 'thor'
require 'xcodeproj'
require_relative 'genzin/cell_generator'

module Genzin
  TEMPLATE_PATH = '/genzin/templates/'

  class GenzinHelper

    # Append a path to the script installation path
    #
    # @param [String] path
    #        the path you want to append
    #
    # @return [String] the path appended to the script installation path
    #
    def self.get_script_path(path='')
      return File.expand_path(File.dirname(__FILE__)) + path
    end

    # Search and select a xcode target inside a xcode project
    #
    # @param [Project] project
    #        the project that hosts the target
    #
    # @return [void, AbstractTarget] the selected target or void if no target is found
    #
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

    # Search and select a .xcodeproj file inside the current folder
    #
    # @return [void, Project] the selected project or void if no project is found
    #
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
    desc 'controller [OPTIONS]','options: --no-viewmodel --no-properties'
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
    def controller
      # Get a project in folder and open it
      project_path = GenzinHelper.choose_project
      return if project_path.nil?
      project = Xcodeproj::Project.open project_path

      # Get a project target
      target = GenzinHelper.choose_target project
      return if target.nil?
    end
  end
end