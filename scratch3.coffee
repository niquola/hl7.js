msg_str = """
MSH|^~\&|GHH LAB|ELAB-3|GHH OE|BLDG4|200202150930||ORU^R01|CNTRL-3456|P|2.4
PID|||555-44-4444||EVERYWOMAN^EVE^E^S^P^^L|JONES|19620320|F|||153 FERNWOOD DR.^^STATESVILLE^OH^35292||(206)3345232|(206)752-121||maritalStatus||AC555444444||67-A4335^OH^20030520||||Y|2||||DateTime|Y|
PV1||E||E|||07369^DORIAN^ARMAND^H^^^MD^^^^^^^|||EMR||||||||E|visit-number|8814|5||||||||||||||||||001|OCCPD||||201101240700
OBR|1|845439^GHH OE|1045813^GHH LAB|15545^GLUCOSE|||200202150730|||||||||
PID|||555-44-4444||DIEGO^Die^D^S^P^^L|JONES|19620320|F|||153 FERNWOOD DR.^^STATESVILLE^OH^35292||(206)3345232|(206)752-121||maritalStatus||AC555444444||67-A4335^OH^20030520||||Y|2||||DateTime|Y|
PV1||E||E|||07369^DORIAN^ARMAND^H^^^MD^^^^^^^|||EMR||||||||E|visit-number|8814|5||||||||||||||||||001|OCCPD||||201101240700
"""

pp = (x)-> console.log(JSON.stringify(x))


comps = (msg, curs)->
  ret = (sel)->
    console.log "search cmp #{sel}"
    res  = []
    for i in curs
      v = msg[i[0]][i[1]].map (x)-> x[sel]
      res.push(v) if v
    res
  ret.msg = msg
  ret.cursors = curs
  ret

fields = (msg, curs)->
  ret = (sel)->
    console.log "search filed #{sel}"
    cursors = []
    for si in curs
      if msg[si][sel]
        cursors.push([si, sel])
    comps(msg, cursors)
  ret.msg = msg
  ret.cursors = curs
  ret

segs = (msg)->
  ret = (sel)->
    if typeof sel == "string"
    else
    console.log "search seg #{sel}"
    cursors = []
    msg.forEach (s,i)->
      if s[0][0][0] == sel
        cursors.push(i)
    fields(msg, cursors)
  ret.msg = msg
  ret


parse = (m)->
  msg = m.split("\n").map (s)->
    s.split("|").map (f)->
      f.split("&").map (c)->
        c.split("^")
  segs(msg)


msg = parse(msg_str)

pid =  msg('PID')
pp pid(5)
pp pid('PV1')


console.log(typeof "a")
