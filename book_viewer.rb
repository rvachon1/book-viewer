require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @toc = File.readlines('data/toc.txt', chomp: true)
end

get "/" do
  @title = "The Adventures of Sherlock Holmes | Table of Contents"

  erb :home
end

get "/chapters/:num" do
  @num = params["num"].to_i

  redirect "/" unless (1..@toc.size).include? @num

  @title = "Chapter #{@num}: #{@toc[@num - 1]}"
  @content = File.read("data/chp#{@num}.txt")

  erb :chapter
end

get "/search" do
  @query = params["query"]
  @search_results = search_chapters(@query)

  erb :search
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(string)
    counter = -1

    string.split("\n\n").map do |paragraph|
      counter += 1
      "<p id=#{counter}>" + paragraph + "</p>"
    end.join
  end

  def bold_match(paragraph, query)
    paragraph.gsub(query, "<strong>#{query}</strong>")
  end
end

def search_chapters(query)
  return nil if (query == nil || query == "")

  results = []

  each_chapter do |number, title, content|
    p_matches = []
    each_paragraph(content.downcase) do |paragraph, idx|
      if paragraph.include?(query.downcase)
        p_matches << { p_idx: idx, p: paragraph }
      end
    end
    results << { chp: number, title: title, matches: p_matches } unless p_matches.empty?
  end

  results.sort_by do |result|
    result[:chp]
  end
end

def each_chapter
  @toc.each_with_index do |title, idx|
    number = idx + 1
    content = File.read("data/chp#{number}.txt")
    
    yield number, title, content
  end
end

def each_paragraph(content)
  content.downcase.split("\n\n").each_with_index do |paragraph, idx|
    yield paragraph, idx
  end
end