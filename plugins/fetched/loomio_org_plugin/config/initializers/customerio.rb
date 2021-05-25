if ENV['CUSTOMERIO_ID']
  $customerio = Customerio::Client.new(ENV['CUSTOMERIO_ID'], ENV['CUSTOMERIO_KEY'])
end
