#!/usr/bin/env ruby

module ViewGenerator
  VALID_PROPERTIES = {
      label:     {
        suffix: 'Label',
        type: 'UILabel',
        attribute: 'text',
        rxbind: 'Driver<String>',
        rxplaceholder: 'Observable.just("").asDriver(onErrorJustReturn: "")'},
      imageview: {
        suffix: 'ImageView',
        type: 'UIImageView',
        attribute: 'image',
        rxbind: 'Driver<UIImage>',
        rxplaceholder: 'Observable.just(UIImage()).asDriver(onErrorJustReturn: UIImage())'},
  }

  # Get a property name and check if it is a valid property
  #
  # @param [String] prompt
  #
  # @return [Array<Hash{String => String}>]
  #
  def get_properties(prompt='property name')
    regex = Regexp.new('(' + VALID_PROPERTIES.keys.join('|') + ')$', true)
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
        prop = VALID_PROPERTIES[m[1].downcase.to_sym]
        properties << {name: property_name.gsub(regex, prop[:suffix]), type: prop[:type], attribute: prop[:attribute], rxbind: prop[:rxbind], rxplaceholder: prop[:rxplaceholder]}
      end
    end
  end

  # Get the snippets for each of the template file sections
  #
  # @param [Array<Hash{String => String}>] properties
  #        The list of properties that will be used to generate the snippets
  # @param [String] snippet_file
  #        The path of the snippet file
  # @param [Regexp] snippet_regexp
  #        The regexp that will extract the template sections from snippet_file
  # @param [Array<Hash{String => String}>] snippet_placeholders
  #        The mapping between the placeholder and the property
  #
  # @return [Array<String>]
  #
  # @note Keep in mind that this function returns the list of snippets
  #       in a specific order defined by the snippet_placeholders
  #
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

  # Generate a new file from a template and the snippets
  # and add it to a Xcode group 
  #
  # @param [String] template_file
  #        The template path relative to the lib folder
  # @param [String] target_dir
  #        The folder to generate the file in
  # @param [PBXGroup] group
  #        The Xcode group to put the file in
  # @param [String] main_placeholder
  #        The placeholder for main_name (next param)
  # @param [String] main_name
  #        The class name (eg. ExampleViewController)
  # @param [Array<String>] placeholders
  #        The template placeholders
  # @param [Array<String>] snippets
  #        The snippets to sub the placeholders
  #
  # @return [PBXFileReference] the new file
  #
  # @note The 'placeholders' and 'snippets' must be in the same order!
  #
  def write_template(template_file, target_dir, group, main_placeholder, main_name, placeholders, snippets)
    template = File.read(get_script_path(template_file))
    new_code = template.gsub(main_placeholder, main_name)
    placeholders.each_with_index do |ph, i|
      new_code.gsub!(ph, snippets[i])
    end
    new_file = "#{target_dir}/#{main_name}.swift"
    out_cell_template = File.new(new_file, 'w')
    out_cell_template.puts(new_code)
    out_cell_template.close
    puts "Created #{main_name}.swift"
    group.new_file("Views/Cells/#{main_name}.swift")
  end
end
