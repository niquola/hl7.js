msg_str = """
MSH|^~\&|GHH LAB|ELAB-3|GHH OE|BLDG4|200202150930||ORU^R01|CNTRL-3456|P|2.4
PID|||555-44-4444||EVERYWOMAN^EVE^E^S^P^^L|JONES|19620320|F|||153 FERNWOOD DR.^^STATESVILLE^OH^35292||(206)3345232|(206)752-121||maritalStatus||AC555444444||67-A4335^OH^20030520||||Y|2||||DateTime|Y|
PV1||E||E|||07369^DORIAN^ARMAND^H^^^MD^^^^^^^|||EMR||||||||E|visit-number|8814|5||||||||||||||||||001|OCCPD||||201101240700
OBR|1|845439^GHH OE|1045813^GHH LAB|15545^GLUCOSE|||200202150730|||||||||
PID|||555-44-4444||DIEGO^Die^D^S^P^^L|JONES|19620320|F|||153 FERNWOOD DR.^^STATESVILLE^OH^35292||(206)3345232|(206)752-121||maritalStatus||AC555444444||67-A4335^OH^20030520||||Y|2||||DateTime|Y|
PV1||E||E|||07369^DORIAN^ARMAND^H^^^MD^^^^^^^|||EMR||||||||E|visit-number|8814|5||||||||||||||||||001|OCCPD||||201101240700
"""

pp = (x)-> console.log(JSON.stringify(x))


_parse = (m)->
  m.split("\n").map (s)->
    s.split("|").map (f)->
      f.split("&").map (c)->
        c.split("^")

zipper = (m, idx)->
  val: ()->
    m[idx]
  name: ()->
    m[idx][0][0][0]
  next: ()->
    zipper(m, idx+1)
  prev: ()->
    zipper(m, idx-1)

_is_vec = (x)->
  Array.isArray(x)

get_in = (obj, path)->
  return null if path.length == 0
  val = obj
  for x in path
    val = val[x]
    break unless val
  val


# pp get_in([1,[1,[1,[1]]]], [1,1,1,0])
#
machine = (desc, path)->
  val: ()->
    get_in(desc, path)
  next: ()->
    npath = path[0..-2].concat(path[path.length-1] + 1)
    machine(desc,npath) if get_in(desc, npath)
  prev: ()->
    npath = path[0..-2].concat(path[path.length-1] - 1)
    machine(desc,npath) if get_in(desc, npath)
  down: ()->
    npath = path[0..-1]
    npath.push(0)
    machine(desc,npath) if get_in(desc, npath)
  up: ()->
    npath = path[0..-1]
    npath.pop()
    machine(desc,npath) if get_in(desc, npath)

parse = (str, struct)->
  msg = _parse(str)
  zipper(msg, 0)

msg = ['MSH','PID', 'PV1', 'PV2','ORC', 'OBR','NTE', 'OBX', 'ORC', 'OBR', 'OBX','OBX']
msg_desc = ['PID', ['PV1', 'PV2'], ['ORC', 'OBR', 'OBX'], 'NTE']

ADT_AO1=  ['PID', ['PV1', '[PV2]'], ['ORC*', '[OBR]', 'OBX*'], '[NTE]*']

{pid: {
  pv1: [{:pv2 '..'}]
  orc: [{
     _seg: [......]
     obr: [
      {obx: [{nte: []}]}]


pp machine(msg_desc, [0]).next().down().next().up().next().val()

msg = parse(msg_str, msg_desc)

# pp  msg.next().next().name()

# resource = (nm, data, cb)->
#   res = {resourceType: nm}
#   el = (nm, data, ccb)->
#     res[nm] = ccb(data) if data
#   cb(el, data)
#   res

# ## take care empty fields and
res = resource 'Patient', (pt)->
  pt.el 'birthDate', new Date()
  pt.els 'name', true, (nm)->
    nm.el 'text', "Hugo Boss"
    nm.els 'familiy', "Hugo"
    nm.els 'given', "Nicola"

  pt.els 'name', (el)->
    el 'text', "Albert Adam Hunigo"
    el 'familiy*', "Albert"
    el 'given*', "Hunigo"
    el 'given*', "Adam"

  el 'contact*', (el)->
    el 'text', 'Some contact'

msg 'PID', (pid)->
  pp "pid"
  pid 'PV1', (pv1)->
    pv1 'PV2', (pv2)->
      pp "pv2"
  pid 'OBR', (obr)->
    pp "obr"
#
msg = parse(msg_str, ['pid',['orc', 'nte', 'obr', ['obx' ,'nte']]])


bundle  (res)->
  msg 'PID', (pid)->
    res 'Patient', (el)->
      pid = uuid()
      el 'id', pid
      pid 5, (name)->
        els 'name', toHumanName(name)
    pid 'ORC', (orc)->
      res 'DiagnosticReport', (dr_el)->
        drid = uuid()
        dr_el 'id', drid
        dr_el 'subject', pid
        orc 'OBX', (obx)->
          res 'Observation', (el)->
            oid = uuid()
            el 'id', oid
            dr_el 'result*', oid
            el 'value', obx(5)
#=> Bundle
      #create order


