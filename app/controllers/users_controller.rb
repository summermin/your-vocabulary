class UsersController < ApplicationController

  def index
  end

  def show
  end

  def get_tweets
    exclude = ["i", "i'm", "i've", "me", "my", "us", "our", "we", "we're",
            "you", "your", "you're", "yours",
            "he", "she", "him", "her", "his", "hers",
            "them", "they", "their", "they're", "it", "it's",
            "who", "whose", "whom", "how",
            "a", "an", "the",
            "am", "is", "are", "was", "were", "be", "being", "been", "has", "have", "had",
            "do", "don't", "did", "will", "won't", "would", "could", "get", "got", "can", "can't",
            "as", "at", "by", "for", "of", "in", "on", "to", "too", "with", "from", "about", 
            "up", "out", "so", "when", "go", "into",
            "and", "but", "or", "yet", "nor",
            "this", "that", "that's", "which", "there", "what", "if",
            "just", "not", "than", "then", "also", "like"]

    first_p   = ["i", "i'm", "i've", "me", "my", "us", "our", "we", "we're"]
    second_p  = ["you", "your", "you're", "yours"]
    third_p   = ["he", "she", "him", "her", "his", "hers",
                 "them", "they", "their", "they're", "it", "it's"]

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["consumer_key"]
      config.consumer_secret     = ENV["consumer_secret"]
      config.access_token        = ENV["access_token"]
      config.access_token_secret = ENV["access_token_secret"]
    end

    tweets = client.user_timeline("#{params[:user_id]}",{count: 200})

    # all_tweets = tweets.map { |tweet| tweet.text }
    all_tweets = tweets.map(&:text).join(" ").downcase
    all_tweets.gsub!(/\brt|[.,?!():;]/,"")

    words = all_tweets.split(" ")

    words = words.select do |word|
              word.strip.match(/^[a-z']+$/)  
            end

    count = Hash.new(0)

    words.each do |word|
      count[word] += 1
    end

    count = Hash[count.sort_by{|k, v| v}.reverse]

    word_list = []
    count.each do |k,v|
      if !exclude.include?(k)
        word_list << {:word => k, :freq => v, :length => k.length}
      end
    end

    avg_length = word_list.collect {|word| word[:length]}.inject(:+).to_f / word_list.size

    pronoun_list = []
    count.each do |k,v|
      if first_p.include?(k)
        pronoun_list << {:word => k, :freq => v, :person => "1st"}
      elsif second_p.include?(k)
        pronoun_list << {:word => k, :freq => v, :person => "2nd"}
      elsif third_p.include?(k)
        pronoun_list << {:word => k, :freq => v, :person => "3rd"}
      end
    end

    respond_to do |format|
      format.html {render action: "show"}
      format.json {render json: {avg_length: avg_length, word_list: word_list, pronoun_list: pronoun_list}}
    end

  end

end