require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/csv.rb'
CSV_TEST_FILE = File.dirname(__FILE__) + '/../csv/test.csv' 

describe Plot do
  
  before(:each) do
    @p = Plot.new('test title')
  end
  
  it "should respond to methods 'numbers' and 'title'" do
    @p.should respond_to(:numbers)
    @p.should respond_to(:title)
  end
  
  it "'numbers' should be an array" do
    @p.numbers.should be_a_kind_of(Array)
  end
end

describe Mephysto_parser do
  
  before(:each) do
    @m = Mephysto_parser.new(CSV_TEST_FILE)
    @first_plot = @m.plots[0]
    @second_plot = @m.plots[1]
  end
  
  it "should have 2 plots (after parsing the test.csv file)" do
    @m.should have(2).plots
  end
  
  it "should have plots of type 'Plot'" do
      @first_plot.should be_a_kind_of(Plot)
  end
  
  it "should get the plot titles from the csv file and set them as the Plot object's title" do
    @first_plot.title.should ==('X151VWHMATCH')
    @second_plot.title.should ==('X152VWHMATCH')    
  end

  it "should get the x,y values from the csv file and give them to their corresponding Plot objects" do
    @first_plot.numbers.should == (FIRST_PLOTS_NUMBERS) #FIRST_PLOTS_NUMBERS defined in spec_helper.rb
  end
end



describe Mephysto_analyzer do
  
  it "should return corresponding y for given x" do
    m = Mephysto_analyzer.new(CSV_TEST_FILE, [-80.0])
    m.plots[0].answers.should ==([31.74])
    m.plots[1].answers.should ==([95.36])
  end
  
  it "should return corresponding ys for bunch of xs" do
    m = Mephysto_analyzer.new(CSV_TEST_FILE, [-80.0,-64.0,-32.0,0.0,32.0,64.0,80.0])
    m.plots[0].answers.should ==([31.74, 35.95, 44.99, 55.39, 69.5, 86.37, 94.66])
    m.plots[1].answers.should ==([95.36, 86.96, 70.42, 55.74, 45.02, 36.19, 31.98])
  end
  
end


# 
# X151VWHMATCH
# -80.0,31.74
# X152VWHMATCH
# -80.0,95.36

  # it "should have cards that show two characters - suite and value" do   
  #    @cards.first.should match(/^[A2-9TJQK][SHDC]$/)
  #    @random_card.should match(/^[A2-9TJQK][SHDC]$/) 
  #  end
  #  
  #  it "should have a spades suite" do
  #    spades = @cards.select {|c| c =~ /^[A2-9TJQK]S$/}
  #    spades.size.should == 13
  #  end
  #  
  #  it "should shuffle itself" do
  #    @deck.shuffle!
  #    top_13_cards = @deck.cards.slice!(0..12)
  #    values = Deck.values_or_suits(top_13_cards,:value)
  #    values.uniq.size.should < 13
  #  end
  #  
  #  it "should return values of cards from array" do
  #    Deck.values_or_suits(['AS','2H'],:value).should == (['A','2'])
  #  end
  #  
  #  it "should return suits of cards from array" do
  #    Deck.values_or_suits(['AS','2H'],:suit).should == ['S','H']
  #  end
  


