# npm install -g coffee-script
# coffee mapper.coffee

net = require('net')
hl7 = require('./src/hl7')

p = (x)->
  console.log(JSON.stringify(x, null, 2))

if (process.argv.length < 6)
  console.log('Usage: coffee mapper.coffee SERVER_HOST SERVER_PORT CLIENT_HOST CLIENT_PORT')
  process.exit(1)

SERVER_HOST = process.argv[2]
SERVER_PORT = process.argv[3]
CLIENT_HOST = process.argv[4]
CLIENT_PORT = process.argv[5]

console.log('SERVER_HOST: ' + SERVER_HOST)
console.log('SERVER_PORT: ' + SERVER_PORT)
console.log('CLIENT_HOST: ' + CLIENT_HOST)
console.log('CLIENT_PORT: ' + CLIENT_PORT)

DESCRIPTION = ["PID", ["NK1"], ["PV1"]]

console.log('DESCRIPTION:')
p(DESCRIPTION)

mapper = (desc, msg) ->
  msg = hl7.v2.parse(desc, msg)
  res = hl7.fhir.resource 'Patient', (pt) ->
    msg 'PID', (pid) ->
      pid 13, (hph) ->
        pt.$els 'telecom', (tel) ->
          tel.$el 'type', 'phone'
          tel.$el 'use', 'home'
          tel.$el 'value', hph(1)

      pid 3, (identifier) ->
        pt.$els 'identifier', (id) ->
          id.$el 'use', 'official'
          id.$el 'value', identifier(1)
          id.$el 'system', "urn:oid:0.1.2.3.4.5.6.7"
          id.$el 'type', coding: [{system: 'http://hl7.org/fhir/v2/0203', code: 'MR'}]

      pid 19, (ssn) ->
        pt.$els 'identifier', (id) ->
          id.$el 'use', 'official'
          id.$el 'value', ssn(1)
          id.$el 'system', "http://hl7.org/fhir/sid/us-ssn"
          id.$el 'type', coding: [{system: 'http://hl7.org/fhir/v2/0203', code: 'SS'}]

      pid 20, (driver_license) ->
        pt.$els 'identifier', (id) ->
          id.$el 'use', 'official'
          id.$el 'value', driver_license(1) + " " + driver_license(2)
          id.$el 'system', "urn:oid:2.16.840.1.113883.4.3.36"
          id.$el 'type', coding: [{system: 'http://hl7.org/fhir/v2/0203', code: 'DL'}]

      pid 14, (hph) ->
        pt.$els 'telecom', (tel) ->
          tel.$el 'type', 'phone'
          tel.$el 'use', 'work'
          tel.$el 'value', hph(1)

      pid 5, (name) ->
        pt.$els 'name', (pt_name) ->
           name 1, (family)->
             pt_name.$els 'family', family
           name 2, (given) ->
             pt_name.$els 'given', given

      pid 7, (birthdate) ->
        bd = birthdate(1)
        pt.$el 'birthDate', bd[0...4] + "-" + bd[4...6] + "-" + bd[6...8]

      pid 8, (sex) ->
        translations =
          M: 'male'
          F: 'female'
          U: 'unknown'

        pt.$el 'gender', translations[sex(1)]

      pid 11, (address) ->
        pt.$els 'address', (ad) ->
          ad.$el 'use', 'home'
          ad.$el 'line', [address(1), address(2)]
          ad.$el 'city', address(3)
          ad.$el 'postalCode', address(5)
          ad.$el 'country', address(6)

      pid 'NK1', (nk) ->
        pt.$els 'contact', (contact) ->
          nk 2, (nk_name) ->
            contact.$els 'name', (contact_name) ->
              contact_name.$el  'use', 'official'
              contact_name.$els 'family', nk_name(1)
              contact_name.$els 'given', nk_name(2)

          nk 3, (nk_type) ->
            contact.$els 'relationship', (contact_rel) ->
              contact_rel.$els 'coding', (contact_rel_code) ->
                contact_rel_code.$el 'code', nk_type(1)
                contact_rel_code.$el 'system', 'http://hl7.org/fhir/patient-contact-relationship'

  res

client = new net.Socket()

server = net.createServer (sock) ->
  console.log('IN: ' + sock.remoteAddress + ':' + sock.remotePort)
  sock.on 'data', (data) ->
    console.log('GET HL7 ' + sock.remoteAddress + ': ' + data)
    console.log('$$$')
    sock.write('GET HL7')
    messages = data.toString().split(/\r\n/)
    p(messages)
    for m in messages
      console.log(m)
      resource = mapper(DESCRIPTION, m)
      json = JSON.stringify(resource)
      console.log('GET JSON')
      p(json)
      client.write(json)
    console.log('FINISHED ##########')
  sock.on 'close', (data) ->
    console.log('IN CLOSED')

client.connect CLIENT_PORT, CLIENT_HOST, () ->
  console.log('OUT: ' + CLIENT_HOST + ':' + CLIENT_PORT)

client.on 'data', (data) ->
  console.log('DATA: ' + data)

client.on 'close', () ->
  console.log('Connection closed')

server.listen(SERVER_PORT, SERVER_HOST)
console.log('Server listening on ' + SERVER_HOST + ':' + SERVER_PORT)
