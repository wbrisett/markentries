require 'bundler/setup'
require 'nokogiri'
require 'creek'
require 'optparse'


@options = {}
optparse = OptionParser.new do |opts|
  opts.banner ="Usage: ruby markentries [options] [excel_file.xslx] [ditamap or bookmap]"
  @options[:multiple] = false
  @options[:single] = false
  @options[:first] = true   # Default is mark only first occurrence in a topic if no options are set.
  opts.on('-f', '--first', 'markup only first occurrence of word in a topic.') do
    @options[:first] = true
  end
  opts.on('-m', '--mulitple', 'markup multiple occurrences of words in a topic.') do
    @options[:multiple] = true
    @options[:first] = false
    @options[:single] = false

  end
  opts.on('-s', '--single', 'markup only a single occurrence of word in map or bookmap.') do
    @options[:multiple] = false
    @options[:first] = false
    @options[:single] = true
  end
  opts.on('-h', '--help', 'Display this screen.') do
    puts opts
    exit
  end
end
optparse.parse!

@topics = Array.new
@terms = Array.new
@surfaceform = Array.new
@directory = Array.new
@maptype = ""


def maptype(themap)
  typemap = themap.xpath("//*").first
  maptypeName = typemap.name.to_s
  if maptypeName.match('bookmap')
   #search = map.xpath("/bookmap/(part|appendices)/descendant::*[contains(@class,' map/topicref ')]/@href")
    search = typemap.xpath("/bookmap/part/descendant::*[contains(@class,' map/topicref ')]/@href | bookmap/appendices/descendant::*[contains(@class,' map/topicref ')]/@href")
  elsif typemap.match('map')
    search = typemap.xpath("/map/descendant::topicref/@href")
  end
return search
end


def glosswrap(para)                # Wraps glossary entries.
  @terms.each_with_index do |singleterm, indx|
    read_buffer = para.to_s
    if read_buffer.include? "\s#{singleterm}"
      all = read_buffer.split(singleterm)  # only want first instance in topic
      all.each_with_index do |text, idx|
        if @options[:first] or @options[:single]
          if idx.eql?(0)
            @writeme = true
            if all[1].split.first.eql?('</abbreviated-form>') # Already marked up, don't need to mark up again.
              all[0] = text + singleterm
            else # Perform action
              all[0] = (text + "<abbreviated-form keyref=\"#{singleterm.downcase.delete(' ').gsub(/[(,)\/\-']/ , '_')}\"/>")
              if @options[:single]   # If only one term in book
                @terms.delete_at(indx)
              end
            end
          else
            all[idx] = (text)
          end
        elsif @options[:multiple]
            @writeme = true
            begin
              if all[idx+1].split.first.eql?('</abbreviated-form>') # Already marked up, don't need to mark up again.
                all[idx] = text + singleterm
              else # Perform action
                all[idx] = (text + "<abbreviated-form keyref=\"#{singleterm.downcase.delete(' ').gsub(/[(,)\/\-']/ , '_')}\"/>")
              end
            rescue => e   # last item no reason to increase index
              all[idx] = (text + "<abbreviated-form keyref=\"#{singleterm.downcase.delete(' ').gsub(/[(,)\/\-']/ , '_')}\"/>")
            end
        end
      end
     para = all.join("")
    end
  end
  return para
end



xlsheet = ARGV[0]
@map = ARGV[1]
@directory = File.dirname(@map)

#Dir::mkdir(@output) unless File.exists?(@output)

doc = Creek::Book.new(xlsheet)   # Read spreadsheet
sheet = doc.sheets[0] # pickup first sheet only
sheet.rows.each.with_index do |row, idx|   # go through each row
  if idx !=0  # Ignore the header row
    @terms.push(row["A#{idx+1}"])  # put each term into an array
  end
end

# Open the map

ditamap = Nokogiri::XML(open(@map))

links = maptype(ditamap)  # determine what type of map is being used, bookmap, standardmap, arm bookmap

links.each do |link|
  @writeme = false  # Only write file if needed.
  #@ditafile = (link.attr('href').to_s)
  file = Nokogiri::XML(open("#{@directory}/#{link}"))
  filetype = file.xpath("/*").first.name # get type of file
  if filetype.eql?("reference")
    topictype = 'refbody'
  elsif filetype.eql?('topic')
    topictype = 'body'
  elsif filetype.eql?('concept')
    topictype = 'conbody'
  elsif filetype.eql?('troubleshooting')
    topictype = 'troublebody'
  elsif filetype.eql?('task')
    topictype = 'taskbody'
  end
  body = file.xpath("//#{topictype}")[0]# Only process the body. No processing short description or title.
  if body.nil?
    @writeme = nil?
  else
    nextelements = body.xpath("//#{topictype}/child::node()")
    replacement = glosswrap(nextelements)
    body.children = replacement
  end

  if @writeme
    File.write("#{@directory}/#{link.to_s}", file)
    puts "Modified : #{@directory}/#{link.to_s}"
  else
    puts "No Changes in: #{@directory}/#{link.to_s}"
  end
rescue
  puts "failed to modify: #{link.to_s}"
end



