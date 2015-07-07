## HL7.js

Collection of libraries to work with HL7 stuff


* HL7v2 parser
* HL7v2 builder
* HL7v2 validator
* FHIR builder
* FHIR parser
* FHIR validator
* FHIR client

FHIR resource builder

```coffee
res = resource 'Patient', (pt)->
  pt.el 'birthDate', new Date()
  pt.els 'name', true, (nm)->
    nm.el 'text', "Hugo Boss"
    nm.els 'familiy', "Hugo"
    nm.els 'given', "Nicola"

  pt.els 'name', (nm)->
    nm.el 'text', "Albert Adam Hunigo"
    nm.els 'familiy', "Albert"
    nm.els 'given', "Hunigo"
    nm.els 'given', "Adam"

  pt.els 'contact', (cnt)->
    cnt.el 'text', 'Some contact'
```


HLv2 parser:

```coffee
ORU_R01 = ['PID',
             ['PV1',
              ['PV2']],
             ['ORC',
               ['OBR',
                 ['NTE'],
                 ['OBX',
                   ['NTE']]]]]

msg = parse(str, ORU_R01)
msg 'PID', (pid)->
  pid 5, (name)->
    console.log name(1)
  pid 'ORC', (orc)->
    console.log orc(3)
    orc 'OBX', (obx)->
       console.log(obx(5))
```

And compose

```coffee
bundle  (res)->
  msg 'PID', (pid)->
    res 'Patient', (pt)->
      pid = uuid()
      pt.el 'id', pid
      pid 5, (name)->
        pt.els 'name', toHumanName(name)
    pid 'ORC', (orc)->
      res 'DiagnosticReport', (dr)->
        drid = uuid()
        dr.el 'id', drid
        dr.el 'subject', pid
        orc 'OBX', (obx)->
          res 'Observation', (obs)->
            oid = uuid()
            obs.el 'id', oid
            dr.el 'result*', oid
            obs.el 'value', obx(5)
```
