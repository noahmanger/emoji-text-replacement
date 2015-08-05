require 'erb'
require 'rubygems'
require 'gemoji'

def get_template()
  %{
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <array>
        <% for @item in @items %>
        <dict>
            <key>on</key>
            <integer>1</integer>
            <key>replace</key>
            <string><%= @item['code'] %></string>
            <key>with</key>
            <string><%= @item['unicode'].force_encoding('utf-8')  %></string>
          </dict>
        <% end %>
      </array>
    </plist>
  }
end

def get_yosemite_template()
  %{
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <array>
        <% for @item in @items %>
        <dict>
          <key>phrase</key>
          <string><%= @item['unicode'].force_encoding('utf-8')  %></string>
          <key>shortcut</key>
          <string><%= @item['code'] %></string>
        </dict>
      <% end %>
      </array>
    </plist>
  }
end

def get_items()

  missing = []
  too_complex = []
  emoji_pairs = []

  Emoji.all.each do |emoji|
    codes   = emoji.aliases.map { |a| ":#{a}:" }
    unicode = emoji.raw

    codes.each do |code|
      if unicode.nil?
        missing << {'code' => code, 'unicode' => code}
      else
        emoji_pairs << {'code' => code, 'unicode' => unicode}
      end
    end
  end

  if missing.any?
    puts "** Emoji present in Github but not in unicode:"
    missing.each {|code| puts " * #{code["code"]}"}
  end

  if too_complex.any?
    puts "** Unicode not currently supported by this script: "
    too_complex.each {|emoji| puts " * #{emoji['code']} - #{emoji['unicode']}"}
  end

  return emoji_pairs
end

class EmojiList
  include ERB::Util
  attr_accessor :items, :template

  def initialize(items, template)
    @items = items
    @template = template
  end

  def render()
    ERB.new(@template, 0, '>').result(binding)
  end

  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end

end


items = get_items

list = EmojiList.new(items, get_template)
list.save(File.join(File.dirname(__FILE__), 'NSUserReplacementItems.plist'))

yosemite_list = EmojiList.new(items, get_yosemite_template)
yosemite_list.save(File.join(File.dirname(__FILE__), 'emoji.plist'))
