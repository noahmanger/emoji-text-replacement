require 'erb'
require 'rubygems'
require 'gemoji'

def get_template()
  %{
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
      </head>
      <body>
        <ul>
          <% for @item in @items %>
          <li><%= @item['unicode'].force_encoding('utf-8')  %> - <%= @item['code'] %></li>
          <% end %>
        </ul>
      </body>
    </html>
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

  return emoji_pairs.sort_by { |ep| ep['code'] }
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

list = EmojiList.new(get_items, get_template)
list.save(File.join(File.dirname(__FILE__), 'index.html'))
