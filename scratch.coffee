msg_str = """
MSH|^~\&|GHH LAB|ELAB-3|GHH OE|BLDG4|200202150930||ORU^R01|CNTRL-3456|P|2.4
PID|||555-44-4444||EVERYWOMAN^EVE^E^S^P^^L|JONES|19620320|F|||153 FERNWOOD DR.^^STATESVILLE^OH^35292||(206)3345232|(206)752-121||maried||AC555444444||67-A4335^OH^20030520||||Y|2||||DateTime|Y|
PV1||E||E|||07369^DORIAN^ARMAND^H^^^MD^^^^^^^|||EMR||||||||E|visit-number|8814|5||||||||||||||||||001|OCCPD||||201101240700
OBR|1|845439^GHH OE|1045813^GHH LAB|15545^GLUCOSE|||200202150730|||||||||
"""

pp = (x)->
  console.log(JSON.stringify(x))

identity = (x)-> x

parse = (s)->
  msg = s.split("\n").map((seg)-> seg.split('|'))
  ret = (sel)->
    segs = msg.filter((seg)-> seg[0] == sel)[0]
    ret = (sfld)->
      return null unless segs
      fld = segs[sfld].split('^')
      ret = (scmp)->
        fld && fld[scmp]
      ret.payload = fld
      ret
    ret.payload = segs
    ret
  ret.payload = msg
  ret

msg = parse(msg_str)

callcb = (o, a, c)->
  if c
    el = (nm, ac, cb)->
      o[nm] = callcb({}, ac, cb) if ac
    c(a, el)
    o
  else
    a

resource = (tp, acc, cb)->
  res = {resourceType: tp}
  callcb(res, acc, cb)
  res

res = resource 'Patient', msg('PID'), (pid, el)->
  el 'name', pid(5), (name, el)->
    el 'text', "#{name(0)} #{name(1)}"
    el 'family', [name(0)]
    el 'given', [name(1)]
  el 'birthDate', pid(7)(0)
  el 'maritalStatus', pid(16)(0)
  if pid(24)
    if pid(25)
      el 'multipleBirthInteger', pid(25)
    else
      el 'multipleBirthBoolean', true
  el 'address', pid(11), (add, el)->
    el 'line', add(0)
    el 'city', add(1)
    el 'sositi', add(2)

pp res
