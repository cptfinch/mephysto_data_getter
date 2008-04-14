require 'rubygems'
require 'fastercsv'

# add the csv directory to the load path ($:)
CSV_DIR = File.dirname(__FILE__) + '/../csv/'
$: << CSV_DIR

class Plot
  attr_accessor :title,:numbers, :answers
  def initialize(title)
    @numbers = []
    @title = title
  end
  
  def normalized_numbers
    norm_val = get_zero_value
    @answers.map { |m| m/norm_val *100  }
  end
  
  def get_zero_value
    @answers.select { |s| s[0] == 0.0 }[1]
  end
  
end

class Mephysto_parser
  
  attr_reader :plots
  
  def initialize(csv_filename)
    @plots = []
    parse(csv_filename)
  end
  
  def get_title(row)
    r = row[0].match(/[X|E]\w*H/) # getting the title that looks something like X151VWHMATCH
    r[0] #return the match
  end
  
  def title_row?(row)
    row[0] =~ (/Group/)
  end

  def get_numbers(row)
    row[0],row[1] = row[0].to_f,row[1].to_f # change numbers from string to float
  end
  
  def numbers_row?(row)
    row[0] =~ (/\A-?\d+\.?\d*\z/)
  end
  
  def read_csv(filename)
    FasterCSV.read(filename)
  end
  
  def create_plot(title)
    @plots << Plot.new(title)
  end
  
  def latest_plot
    @plots.last
  end
  
  def parse(filename)
    csv = read_csv(filename)
    csv.each do |row|
      if title_row?(row)
        title = get_title(row)
        create_plot(title)
      end  
      latest_plot.numbers << get_numbers(row) if numbers_row?(row)
    end
  end 
  
end

class Mephysto_analyzer
  
  def plots
    @parser.plots
  end
  
  def initialize(filename, numbers_to_analyze,outputter = Csv_outputter.new)
    @parser = Mephysto_parser.new(filename)
    analyze(numbers_to_analyze)
    output(outputter,numbers_to_analyze)
  end
  
  def analyze(numbers_to_analyze)
    # plots = @parser.plots
    plots.each  do |plot|  
      plot.answers = get_answers(plot.numbers, numbers_to_analyze)
    end
    # @answers = plots.map { |plot| get_answers(plot,numbers_to_analyze) }
  end
  
  def get_answers(numbers,numbers_to_analyze)
    find_ys_for_given_xs(numbers,numbers_to_analyze) #returns an array of arrays that can then be written to csv as two columns
  end
  
  def pairs_x_matches_desired_x?(xy_pair, x)
    xy_pair[0] == x
  end
  
  def find_ys_for_given_xs(plots_xy_pairs, numbers_to_analyze)
    answers=[]
    numbers_to_analyze.each do |x|  
      plots_xy_pairs.each do |xy_pair|
        answers << get_y(xy_pair) if pairs_x_matches_desired_x?(xy_pair, x)  
      end
    end 
    answers
  end
  
  def get_y(xy_pair)
    xy_pair[1]
  end

  def output(outputter,numbers_to_analyze)
    outputter.output(plots,numbers_to_analyze)
  end

end

class Csv_outputter
  
  # def initialize(plots,numbers_to_analyze)
  #   output(plots,numbers_to_analyze)
  # end
  
  def zip_together_x_and_y(plots, numbers_to_analyze)
    plots.map do |plot|
      numbers_to_analyze.zip(plot.answers).unshift(plot.title)
    end
  end
  
  def give_to_csv(data_row)
    FasterCSV.open(CSV_DIR+"/test_output.csv", "w") do |csv_row|
      csv_row << data_row
    end      
  end
  
  def output(plots, numbers_to_analyze, filename = 'test_output.csv')
    data = zip_together_x_and_y(plots, numbers_to_analyze)
    
    FasterCSV.open(CSV_DIR+filename, 'w+') do |csv_row|
      data.each do |d|
        d.each do |data_row|
          csv_row << data_row          
        end
      end
    end

  end
  
end

# ans = get_y(80.0,numbers)
# puts ans
# numbers.each { |e| print e;puts e[0].class }
