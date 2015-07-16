# npm install -g coffee-script
# coffee aquiel.coffee

hl7  = require('./src/hl7')
p = (x)->
  console.log(JSON.stringify(x, null, 2))

msg_desc = ["PID", ["NK1"], ["PV1"]]

msg_str = """
MSH|^~&|EPICADT|DH|LABADT|DH|201301011226||ADT^A01|HL7MSG00001|P|2.3|
EVN|A01|201301011223||
PID|||MRN12345^5^M11||APPLESEED^JOHN^A^III&Alias^Alias^A^||19710101|M||C|1 CATALYZE STREET^^MADISON^WI^53005-1020|GL|(414)379-1212|(414)271-3434||S||MRN12345001^2^M10|123456789|987654^NC|
NK1|1|GEORGE^FRED^J|WIFE||||||NK^NEXT OF KIN
PV1|1|I|2000^2012^01||||004777^GOOD^SIDNEY^J.|||SUR||||ADM|A0|
"""

msg = hl7.v2.parse(msg_desc, msg_str)

xpn_HumanName = (xpn, HumanName)->
          if xpn
                    use: 'usual',
                    family: [xpn[0]],
                    given: [xpn[1]],
                    prefix: [xpn[4]],
                    suffix: [xpn[3]]
    pid 5, (name) ->      
      pt.$els 'name', (pt_name) ->
         name 1, (family)->
           pt_name.$els 'family', family
         name 2, (given) ->
           pt_name.$els 'given', given

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

# p(res)

assert = require("assert")

assert.equal(2, res.name.length)

assert.equal(1, res.name[0].family.length)
assert.equal("APPLESEED", res.name[0].family[0])
assert.equal(1, res.name[0].given.length)
assert.equal("JOHN", res.name[0].given[0])

assert.equal(1, res.name[1].family.length)
assert.equal("Alias", res.name[1].family[0])
assert.equal(1, res.name[1].given.length)
assert.equal("Alias", res.name[1].given[0])
