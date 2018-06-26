require 'sinatra'
require 'active_support/all'
require 'json'
require 'config'
require 'rest-client'
require_relative 'helpers/tooltip_helpers'
require_relative 'helpers/airport_helpers'
require 'pry'
# require_relative '../helpers/application_helper'

###
class AirlineDemo < Sinatra::Application
  # set folder for templates to ../views, but make the path absolute
  set :views, File.expand_path('../views', __FILE__)
  set :public_folder, 'public'
  # don't enable logging when running tests
  configure :production, :development do
    enable :logging
  end


  register Config

  # a = show_message('')
  def url_nlu 
    uri = ENV['AIRLINE_NLU_URL'] || 'http://139.162.53.9:8899/nlu'
    uri
  end

  def url_auto_correct
    uri = ENV['AIRLINE_AUTOCORRECT_URL'] || 'http://139.162.53.9:8890/autocorrect'
    uri
  end

  def show_message(message)
    @noti_message = message
  end

  def call_nlu(message)
    response = RestClient.post(url_nlu, {'text': message }) { |response, request, result, &block|
      result_body = response.body
      result_json = JSON.parse(result_body)
      return result_json
    }
  end

  def parse_nlu_result(result)
    
    @intent = result['intention_tag'].humanize if result['intention_tag']
    @sub_intent = result['semantic_tag'].humanize if result['semantic_tag']

    time_begin = result['departure_start_time'] if result['departure_start_time']
    time_end = result['departure_end_time'] if result['departure_end_time']

    date_begin = result['departure_start_date'] if result['departure_start_date']
    date_end = result['departure_end_date'] if result['departure_end_date']

    @departure_datetime_begin = "#{date_begin} #{time_begin}".strip
    @departure_datetime_end = "#{date_end} #{time_end}".strip

    return_time_begin = result['return_start_time'] if result['return_start_time']
    return_time_end = result['return_end_time'] if result['return_end_time']

    return_date_begin = result['return_start_date'] if result['return_start_date']
    return_date_end = result['return_end_date'] if result['return_end_date']
    
    @return_datetime_begin = "#{return_date_begin} #{return_time_begin}".strip
    @return_datetime_end = "#{return_date_end} #{return_time_end}".strip

    @departure_city = result['departure_province']
    @destination_city = result['destination_province']
    @departure_airport = result['departure_code']
    @destination_airport = result['destination_code']

  end

  def parse_nlu_result2(result)
    @intent = result['intention_tag'].humanize if result['intention_tag']
    @booking_info = result['booking_information']
    # binding.pry
    puts @booking_info
  end

  def call_auto_correct(message)
    req = RestClient.post url_auto_correct, {'text': message }
    result = req.body
  end

  def call_click_bait(message)
    req = RestClient.gett url_auto_correct, {'text': message }
    result = req.body
  end

  get '/' do
    erb :demo2
  end

  def call_clickbait (message)
    p message

    click_bait_url = 'https://char-bait-detect.herokuapp.com/bait'
    response = RestClient.get(click_bait_url, :params => {:text => message}) { |response, request, result, &block|
      result_body = response.body
      # result_json = JSON.parse(result_body)
      return result_body
    }

  end
  def filter_text(text)
    text=text.gsub('!', '')
  end
  post '/' do
    @text = params["text"]
   
    @text = filter_text @text 
    if @text.present?
      begin
        @click_bait_result = call_clickbait @text

      #   @corrected_message = call_auto_correct(@text)

      #   @nlu_result = call_nlu(@corrected_message)
        
      #   @norm_text = @nlu_result['nlu_result']['norm_text'] if @nlu_result['nlu_result']['norm_text']
      #   semi_norm = @nlu_result['nlu_result']['semi_norm_text'].clone if @nlu_result['nlu_result']['semi_norm_text']
      #   extraction_result = @nlu_result['nlu_result']['keyword_extraction_result'] if @nlu_result['nlu_result']['keyword_extraction_result']
      #   @semi_norm_text = render_tooltip(semi_norm,extraction_result)
      #   interpretation = @nlu_result['interpretation'] if @nlu_result['interpretation']
      #   parse_nlu_result2(interpretation)
      # rescue Exception => e  
      #   puts e.message  
      #   puts e.backtrace.inspect
        
      #   show_message 'Something wrong'
      #   @nlu_result
        
      end 
    else
      show_message 'Please enter text'
    end
    erb :demo2
  end

  get '/_old' do
    erb :demo
  end

  post '/_old' do
    # show_message 'this is post'
    text = params["text"]
    @text = text
    
    if text.present?
      begin
        corrected = call_auto_correct(text)
        @corrected_message = corrected
        
        @nlu_result = call_nlu(corrected)
    
        @norm_text = @nlu_result['norm_text'] if @nlu_result['norm_text']
        semi_norm = @nlu_result['semi_norm_text'].clone if @nlu_result['semi_norm_text']
        
        extraction_result = @nlu_result['keyword_extraction_result'] if @nlu_result['keyword_extraction_result']
        @semi_norm_text = render_tooltip(semi_norm,extraction_result)
        keyword_result = @nlu_result['keyword_result'][0] if @nlu_result['keyword_result']
        parse_nlu_result(keyword_result)
      rescue Exception => e  
        puts e.message  
        puts e.backtrace.inspect  
      end 
    else
      show_message 'Please enter text'
    end
    erb :demo
  end

  def call_mock2()
    result = {
      session_id: "xxxxxx",
      return_code: "",
      return_message: "",
      nlu_result: {
        original_text: "จองตั๋ว กทม เชียงใหม่ พรุ่งนี้ช่วงเช้า เชียงใหม่ ไปเชียงราย วันพุธเย็น เชียงรายกลับ กทม วันศุกร์",
        norm_text: "จอง ตั๋ว %province_name% %province_name% พรุ่งนี้ ช่วง เช้า %province_name% ไป %province_name% วัน พุธ เย็น %province_name% กลับ %province_name% วัน ศุกร์",
        semi_norm_text: "จอง ตั๋ว กรุงเทพ เชียงใหม่ พรุ่งนี้ ช่วง เช้า เชียงใหม่ ไป เชียงราย วัน พุธ เย็น เชียงราย กลับ กรุงเทพ วัน ศุกร์",
        semantic_tag: "",
        semantic_id: "",
        keyword_extraction_result: {
          "กรุงเทพ": "province",
          "เชียงใหม่": "province",
          "พรุ่งนี้": "2017-08-16-Wednesday",
          "ช่วงเช้า": "morning",
          "เชียงราย": "province",
          "วัน พุธ": "2017-08-16-Wednesday",
          "เย็น": "early_evening",
          "วัน ศุกร์": "2017-08-18-Friday"
        }
      },
      interpretation: {
        intention_id: "",
        intention_tag: "booking",
        booking_information: [
          {
            departure:{
              date: {
                start: "2017-08-16",
                end: "2017-08-16"
              },
              time: {
                start: "04:00",
                end: "08:59"
              },
              time_period: ["morning"],
              province: "กรุงเทพ",
              airport: ["DMK", "BKK"]
            },
            destination: {
              province: "เชียงใหม่",
              airport: ["CNX"]
            }
          },
          {
            departure: {
              date: {
                start: "2017-08-16",
                end: "2017-08-16"
              },
              time: {
                start: "16:00",
                end: "18:59"
              },
              time_period: ["early_evening"],
              province: "เชียงใหม่",
              airport: ["CNX"]
            },
            destination: {
              province: "เชียงราย",
              airport: ["CEI"]
            }
          },
          {
            departure:{
              date: {
                start: "2017-08-18",
                end: "2017-08-18"
              },
              province: "เชียงราย",
              airport: ["CEI"]
            },
            destination:{
              province: "กรุงเทพ",
              airport: ["DMK", "BKK"],
            }
          }
          ],
        is_round_trip: "true"
      }
    }
    JSON.parse(result.to_json)
  end


  # if run by pure ruby
  if __FILE__ == $0
    run!
  end

end
# run AirlineDemo

