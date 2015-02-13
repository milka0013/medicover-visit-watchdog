#!/usr/bin/ruby
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'
require 'json/pure'

ContentURI = URI.parse("https://mol.medicover.pl/api/MyVisits/SearchFreeSlotsToBook?language=pl-PL")
#ContentURI.path

@toSend = {
    "regionId" => 200,
    "bookingTypeId" => 2,
    "specializationId" => 3,
    "clinicId" => -1,
    "languageId" => -1,
    "doctorId" => -1,
    "searchSince" => "2015-02-13T02:00:00.000Z",
    "searchForNextSince" => "2015-02-13T23:00:00.000Z",
    "periodOfTheDay" => 0,
    "isSetBecauseOfPcc" => false,
    "isSetBecausePromoteSpecialization" => false
}
  
req = Net::HTTP::Post.new('/api/MyVisits/SearchFreeSlotsToBook?language=pl-PL', initheader = {
  'X-Requested-With' => 'XMLHttpRequest',
  'Content-Type' =>'application/json', 
  'Cookie' => '.ASPXAUTH=84D272C489DFE80981248D886901CE15DE53B9E30AF1AA9469AF3D131AE4CD1B51CCB758757E9C75FE1E49F13638069997D74BB7426B84C9E4EBC4DABEEB9506897F2E632419E2934DE8D5E65183E237B671F3D31B2601451817513EB2C49294E9CBDFE55CA547E6F17B37387513B61FD7F817B9576345FCF6846E70D4416CF3C7ADB805FD2F77E161A8104B6EA7AFCFD4D06E8CBB2F9060D7C266563B47EFCC44A86C5BF56B63BA44186119B740EC9777D4EB94E1B2AEBD480E2E8B2C5591B25ED8661E438DF7CC267D57C050BE659746512815920F86EFC33328570B21E46643CC5E8FBC32DACEBE73674CC56C04B3155F796C62E0FAFE17E741899920C2328FBF87D66BE5CADB9B20EF0AE4AB4CA2D6235431567769C2BDA8AA7C3D608C01489033CA4A29294B99D7EAE2B248CCC6780CCE0B70B43B1E588F88415B83307FBA35DDD7776672483C74D8DB0A59E44DA3BB7552EADE8FDF7BF6FB6FCD3EE1C01DD28590EF7043CA66DE3CF93D8F366D1A24176749967241E856161951CA3010AADBAE302B1920E6FCB24828B4E918BD2481CC034AEA68B1371D5057F305CA2F8D6C0A3252891CBEE431A9288159EE60E819521CD7142E2863D05264B8CE4E3F99BBDA319E49F50CF21C51BC2ADE4D13C7066F37E1F8ED8F368FD95C0CE0DAFC0D33D6DC2EC8B4FE47335E6E43942CA7;'
  })

req.body = "#{@toSend.to_json}"
https = Net::HTTP.new(ContentURI.host, ContentURI.port)
https.use_ssl = true
resp = https.start { |cx| cx.request(req) }
# p @toSend
p resp
p resp.message
p resp.body
respJson = JSON.parse(resp.body)
p respJson['FirstPossibleAppointmentDate']
p respJson
