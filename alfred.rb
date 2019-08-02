require "json"

module Alfred

  def self.display(entries=[])
    puts({:items => Array(entries)}.to_json)
  end

  class Item
    attr_accessor :uid, :title, :subtitle, :arg, :icon, :valid, :autocomplete
    attr_accessor :type, :mods, :text, :quicklook, :variables

    # uid          - optional unique identifier for alfred to learn from
    # title        - title displayed in the result row
    # subtitle     - optional subtitle displayed in the result row
    # arg          - recommended string argument to pass through to output action
    # icon         - optional icon argument
    # valid        - true or false, default true. valid means "actionable item".
    #                false means the autocomplete text will be populated.
    # autocomplete - recommended string to autocomplete with tab key
    # type         - "default", "file", "file:skipcheck", default "default".
    #                Treat the result as a file.
    # mods         - optional modifier keys object.
    # text         - optional text if copied to clipboard or displayed large text.
    # quicklook    - optional string url for quicklook.
    def initialize(opts={})
      @uid = opts.fetch :uid, nil
      @title = opts.fetch :title
      @subtitle = opts.fetch :subtitle, nil
      @arg = opts.fetch :arg, nil
      @icon = opts.fetch :icon, nil
      @valid = opts.fetch :valid, true
      @autocomplete = opts.fetch :autocomplete, nil
      @type = opts.fetch :type, nil
      @mods = opts.fetch :mods, nil
      @text = opts.fetch :text, nil
      @quicklook = opts.fetch :quicklook, nil
      @variables = opts.fetch :variables, nil
    end

    def to_json(*args)
      data = {
        uid: @uid,
        title: @title,
        subtitle: @subtitle,
        arg: @arg,
        icon: @icon,
        valid: @valid,
        autocomplete: @autocomplete,
        type: @type,
        mods: @mods,
        text: @text,
        quicklook: @quicklook,
        variables: @variables,
      }.reject { |k,v| v.nil? }.flatten
      Hash[*data].to_json(*args)
    end
  end

  class Icon
    #   type - optional, can be "fileicon" for a path, or "filetype" for a
    #          specific file
    #   path - the path to a file
    def initialize(opts={})
      @path = opts.fetch(:path)
      @type = opts.fetch(:type, nil)
    end

    def to_json(*args)
      if @type
        {path: @path, type: @type}.to_json(*args)
      else
        {path: @path}.to_json(*args)
      end
    end
  end

  class Text
    # copy - text to copy with (cmd-c)
    # largetype - text to display with large type (cmd-L)
    def initialize(opts={})
      @copy = opts.fetch(:copy, nil)
      @largetype = opts.fetch(:largetype, nil)
    end

    def to_json(*args)
      data = {:copy => @copy, :largetype => @largetype}.reject { |k, v| v.nil? }.flatten
      Hash[*data].to_json(*args)
    end
  end

  class Modifiers
    def initialize(alt: nil, cmd: nil, shift: nil)
      @alt = alt
      @cmd = cmd
      @shift = shift
    end

    def to_json(*args)
      data = {alt: @alt, cmd: @cmd, shift: @shift}.reject { |k, v| v.nil? }.flatten
      Hash[*data].to_json(*args)
    end
  end

  class Modifier
    def initialize(valid: true, arg:, subtitle: nil, variables: nil)
      @valid = valid
      @arg = arg
      @subtitle = subtitle
      @variables = variables
    end

    def to_json(*args)
      data = {valid: @valid, arg: @arg, subtitle: @subtitle, variables: @variables}.reject { |k, v| v.nil? }.flatten
      Hash[*data].to_json(*args)
    end
  end

  class Variables
    def initialize(variables={})
      @variables = variables
    end

    def to_json(*args)
      variables.to_json(*args)
    end
  end

end
