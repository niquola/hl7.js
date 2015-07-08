callcb = (o, a, c)->

_is_fn = (x)-> typeof(x) == "function"
_is_vec = (x)-> Array.isArray(x)
_is_obj = (x)-> Object.prototype.toString.call(x) == '[object Object]'

mk_builder = (obj)->
  obj.$el = (attr, cb_or_v)->
    console.log(attr, cb_or_v)
    if _is_fn(cb_or_v)
      nobj = {}
      obj[attr] = nobj
      cb_or_v(mk_builder(nobj))
    else
      obj[attr] = cb_or_v if cb_or_v?
  obj.$els = (attr, cb_or_v)->
    if _is_fn(cb_or_v)
      nobj = mk_builder({})
      cb_or_v(nobj)
      (obj[attr] ||= []).push(nobj)
    else
      (obj[attr] ||= []).push(cb_or_v) if cb_or_v?
  obj

clear$ = (x)->
  if _is_vec(x)
    x.map(clear$)
  else if _is_obj(x)
    obj = {}
    for k,v of x when k.indexOf('$') != 0
      obj[k] = v
    obj
  else
    x


resource = (tp, cb)->
  res = {resourceType: tp}
  cb(mk_builder(res))
  clear$(res)

exports.resource = resource

bundle = (cb)->
  entry = []
  bndl = {etntry: entry}
  bndl.$entry = (tp, cb)->
    entry.push(resource(tp,cb))
  cb(bndl)
  bndl

exports.bundle = bundle
