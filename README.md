## HL7.js

Collection of libraries to work with HL7 stuff


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
