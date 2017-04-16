#!/usr/bin/env ruby

module GenericGenerator
  def get_properties(valid_properties, prompt='property name')
    regex = Regexp.new('(' + valid_properties.keys.join('|') + ')$', true)
    properties = []
    while true
      print "\n#{prompt.capitalize} (empty to quit): "
      property_name = STDIN.gets.chomp.strip
      if property_name.empty?
        return properties.sort_by { |p| p[:name] }
      end
      m = regex.match(property_name)
      if m.nil?
        puts "\nInvalid #{prompt}: #{property_name}"
      else
        prop = valid_properties[m[1].downcase.to_sym]
        properties << {name: property_name.gsub(regex, prop[:suffix]), type: prop[:type], reactor_property: prop[:reactor_property]}
      end
    end
  end

  def get_snippets(properties, snippet_file, snippet_regexp, snippet_placeholders)
    sections = nil
    script_dir = File.dirname(File.expand_path(__FILE__))
    snippet_file = File.expand_path(script_dir + '/' + snippet_file)
    if File.exists?(snippet_file)
      snippet = File.read(snippet_file)
      m = snippet.match(snippet_regexp)
      unless m.nil?
        sections = Array.new(m.length-1, '')
        properties.each do |prop|
          (1..m.length-1).each do |s|
            section_code = m[s]
            snippet_placeholders.each do |ph|
              section_code.gsub!(ph[:placeholder], prop[ph[:property_field]])
            end
            sections[s-1] += section_code + "\n"
          end
        end
      end
    end
    sections
  end
end
