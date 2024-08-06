// Queue | QUEUE

export class Queue extends Map {
}

export const queue = () => {
  const queue = new Queue()
  return queue
}
// node to be rendered
// expected elements whose gost node has been 
// modified by reactions from controllers
Queue.prototype.eradicate = function(node) {
  if (!this.has('eradicate')) this.set('eradicate',new Set())
  this.get('eradicate').add(node)
  return this
}
// nodes added to banish will be banished and banned from rendering
// this is some kind of hard filter out when not displaying is not enough
// node will need to be essentiated again and rendered (alias spawn) to come back in the dom world
Queue.prototype.banish = function(node) {
  if (!this.has('banish')) this.set('banish',new Set())
  this.get('banish').add(node)
  return this
}
Queue.prototype.essentiate = function(node) {
  if (!this.has('essentiate')) this.set('essentiate',new Set())
  this.get('essentiate').add(node)
  return this
}
Queue.prototype.render = function(node) {
  if (!this.has('render')) this.set('render',new Set())
  this.get('render').add(node)
  return this
}
Queue.prototype.actuate = function(node) {
  if (!this.has('actuate')) this.set('actuate',new Set())
  this.get('actuate').add(node)
  return this
}
// if you can't bother selecting node to render
// just add body here, and render the whole tree after
// Queue.prototype.body = function(body) {
//   if (this.has('body')) console.warn("already have a body registered")
//   this.set('body',body)
//   return this
// }
// happen before any queue rendering 
// should hold any kind of hard filtering :
// removing nodes from both tree or making ones unrenderable
// or essentiating back a node that was banned (removed from dom tree but 
// still alive in gost tree)
// it will happen before each queue.update() call
// if you put a queue.render inside you will endless death recursion loop
// but you can add nodes to queue
Queue.prototype.intro = function(echo) {
  if (!this.has('intro')) this.set('intro',new Set())
  this.get('intro').add(echo)
  return this
}
// happen after queue rendering
// should hold soft display update/filering
// like updating counters of changing appearance depending of tree state
// you cannot call queue.update() from here or you will endless loop of death
Queue.prototype.outro = function(echo) {
  if (!this.has('outro')) this.set('outro',new Set())
  this.get('outro').add(echo)
  return this
}
// apply all modification from gost tree to dom tree
// if you did not bother adding just the altered nodes and provided a body
// the queue.render('body') will update the whole dom tree
// call any function in intro
// eradicate any node in kill
// render any node in render
// flush kill and render
// call any function in outro 
Queue.prototype.update = function(){
  // ERADICATE
  this.get('eradicate')?.forEach(inside=>{
    if (typeof(inside) == 'function') inside()
    if (inside instanceof Map) node.eradicate() 
  })
  this.get('eradicate')?.clear()
  // BAN
  this.get('banish')?.forEach(inside=>{
    if (typeof(inside) == 'function') inside()
    if (inside instanceof Map) node.banish() 
  })
  this.get('banish')?.clear()
  // ESSENTIATE
  this.get('essentiate')?.forEach(inside=>{
    if (typeof(inside) == 'function') inside()
    if (inside instanceof Map) node.essentiate() 
  })
  this.get('essentiate')?.clear()
  // INTRO
  this.get('intro')?.forEach(echo=>echo())
  // RENDER
  this.get('render')?.forEach((inside)=>{
    if (typeof(inside) == 'function') inside()
    if (inside instanceof Map ) inside.render() 
  })
  this.get('render')?.clear()
  // ACTUATE
  this.get('actuate')?.forEach((inside)=>{
    if (typeof(inside) == 'function') inside()
    if (inside instanceof Map ) inside.actuate() 
  })
  this.get('actuate')?.clear()
  // OUTRO
  this.get('outro')?.forEach(echo=>echo())
  return this
}


