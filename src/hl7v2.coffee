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

_last= (x)-> x[x.length - 1]

_null = -> null

zipper = (tree, path)->
  if path.length == 0
    return { val: null, up: _null, right: _null, left: _null, down: -> zipper(tree, [0])}

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
  path = (zip)->
    return [] unless zip.val
    res = [zip.val]
    up = zip.up()
    while up
      val = up.val
      res.push(val) if val
      up = up.up()
    res.reverse()
  move_to = (zip, cb)->
    cb(path(zip))
    machine(zip)

  state: -> zip.val
  next: (word, cb)->
    return move_to(zip, cb) if word == zip.val
    ch = zip.down()
    while ch
      return move_to(ch, cb) if word == ch.val
      ch = ch.right()
    up = zip
    while up
      return move_to(up, cb) if word == up.val
      rght = up.right()
      while rght
        return move_to(rght, cb) if word == rght.val
        rght = rght.right()
      up = up.up()
    # ignore
    machine(zip)

_parse = (m)->
  m.split("\n").map (s)->
    s.split("|").map (f)->
      f.split("&").map (c)->
        c.split("^")

mk_fld_sel = (fld)->
  (sel, cb)->
    x = fld[sel - 1]
    if cb then cb(x) if x else x

_is_num = (x)-> not isNaN(x * 1)

mk_msg = (res)->
  (sel, cb)->
    if _is_num(sel)
      for x in (res.$seg[sel] || [])
        cb(mk_fld_sel(x))
    else
      for x in (res[sel] || [])
        cb(mk_msg(x))


_msg = (desc, raw_msg)->
  msg = _parse(raw_msg)
  m = machine(zipper(desc, []))
  res = {$pth: []}
  cur_node = res
  for seg in msg
    seg_nm = seg[0][0][0]
    m = m.next seg_nm, (pth)->
      ppth = cur_node.$pth
      lst = _last(pth)
      new_node = {$seg: seg, $up: cur_node, $pth: pth}
      if pth.length <= ppth.length
        # walking up to common node
        until cur_node && cur_node.$pth.toString() == pth[0..-2].toString()
          cur_node = cur_node.$up
      cur_node[lst] ||= []
      cur_node[lst].push(new_node)
      cur_node = new_node
  res

parse = (desc, msg)->
  mk_msg(_msg(desc, msg))

module.exports = parse
