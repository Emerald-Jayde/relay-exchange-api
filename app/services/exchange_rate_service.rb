require 'rest-client'

class ExchangeRateService
  
    def initialize
      @next_update = nil
    end

    def call
      if @next_update.nil? or (Time.now > @next_update)
        response = RestClient.get "#{exchangerate_url}"
        json = JSON.parse response
        
        currencies_array = []
        for currency in json['rates'] do
            currencies_array << { name: currency[0], rate: currency[1] }
        end
        
        Currency.upsert_all(currencies_array, unique_by: :name) 
        @next_update = json['time_next_update_utc']
      end
    end

    def exchangerate_url
      'https://open.exchangerate-api.com/v6/latest'
    end
end