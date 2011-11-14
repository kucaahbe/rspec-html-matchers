class Asset
  @@assets = {}

  PATH = File.expand_path(File.join(File.dirname(__FILE__),'..','assets','*.html'))

  def self.[] name
    @@assets[name.to_s]
  end

  def self.<< asset
    @@assets.merge! asset.name => asset
  end

  def self.list
    @@assets.keys
  end

  attr_reader :name

  def initialize name, path
    @name = name
    @path = path
  end

  def content
    @content ||= IO.read(@path)
    puts @content
    return @content
  end
  alias_method :c, :content
end

puts 'assets list:'
Dir[Asset::PATH].each do |asset_path|
  asset_name = File.basename(asset_path,'.html')
  puts asset_name
  Asset << Asset.new(asset_name,asset_path)
end
