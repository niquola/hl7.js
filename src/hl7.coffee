parse  = require('./hl7v2')
fhir = require('./fhir')

module.exports = {
  v2: {parse: parse}
  fhir: fhir
}
