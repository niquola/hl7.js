pp = (a...)-> console.log(JSON.stringify(a))

get_in = (obj, path)->
  for x in path
    obj = obj[x]
    break unless obj
  obj

_is_vec = (x)-> Array.isArray(x)

inc_last = (path, inc)->
  idx = path[path.length - 1]
  ppath = path[0..-2]
  ppath.concat([idx + inc])

_null = -> null

zipper = (tree, path)->
  if path.length == 0
    return { val: _null, up: _null, right: _null, left: _null, down: -> zipper(tree, [0])}

  idx = path[path.length - 1]
  ppath = path[0..-2]
  val = get_in(tree, path)
  val: val
  down: ->
    npath = ppath.concat([idx + 1, 0])
    # TODO: may be check value after
    # so val will return null not down, up, right
    # cursor problem emacs vs vim :)
    zipper(tree,npath) if get_in(tree, npath)
  up: ->
    npath = if ppath.length == 0 then [] else ppath[0..-2].concat([0])
    zipper(tree,npath)
  right: ->
    npath = inc_last(ppath,1).concat([0])
    zipper(tree,npath) if get_in(tree, npath)
  left: ->
    npath = inc_last(ppath,-1).concat([0])
    zipper(tree,npath) if get_in(tree, npath)



machine = (zip)->
  pp "Enter #{zip.val}"

  state: -> zip.val
  # TODO: move path to zipper
  # should return vec of zippers
  path: ->
    res = [zip.val]
    up = zip.up()
    while up
      val = up.val
      res.push(val)  if val
      up = up.up()
    res.reverse()
  next: (word)->
    return machine(zip) if word == zip.val
    ch = zip.down()
    while ch
      return machine(ch) if word == ch.val
      ch = ch.right()
    up = zip
    while up
      return machine(up) if word == up.val
      rght = up.right()
      while rght
        return machine(rght) if word == rght.val
        rght = rght.right()
      up = up.up()
    # ignore
    machine(zip)


msg = ['PID', 'PV1', 'PV2','ORC', 'OBR', 'OBX', 'NTE', 'NTE', 'OBX', 'ORC', 'OBR', 'OBX','OBX']

msg_desc = ['PID',                 # [0]
             ['PV1',               # [1, 0]
              ['PV2']],            # [1, 1, 0]
             ['ORC',               # [2, 0]
               ['OBR'],            # [2, 1,0]
               ['NTE'],            # [2, 2,0]
               ['OBX', ['NTE']]]]  # [2, 3, 1, 0]


m = machine(zipper(msg_desc, []))

for seg in msg
  pp seg
  m = m.next(seg)
  pp "-> Enter #{m.path()}"
