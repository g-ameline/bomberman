
// Reaction | REACTION

export class Reaction extends Map {
}

export const reaction = () => {
  const new_reaction = new Reaction()
  return new_reaction
}
Reaction.prototype.kedge = function(node) {
  return kedge(this,node)
}
export const kedge = (reaction,node) => {
  if (!(node instanceof Map)) throw new Error(`node,${node} (${typeof(node)}) should be a gost (node or sock ..) `)
  reaction.set('kedge',node)
  return reaction
}
Reaction.prototype.trigger = function(happening) {
  return trigger(this,happening)
}
export const trigger = (reaction,happening) => {
  if (typeof happening !== 'string') throw new Error(`trigger must take a string and not that ${typeof(happening)}`)
  reaction.set('trigger',happening)
  return reaction
}
Reaction.prototype.action = function(callback) {
  return action(this,callback)
}
export const action = (reaction,callback) => {
  if (typeof callback != 'function') throw("action ${callback} ${typeof(callback)} should be a function")
  reaction.set('action',callback)
  return reaction
}
Reaction.prototype.option = function(config) {
  this.set('option',config)
  return this
}
// actuate , activate the Reaction
Reaction.prototype.actuate = function() {
  actuate(this)
}
// Reaction.prototype.actuate = function() {
export const actuate = (reaction) => {
  const kedge = reaction.get('kedge')
  const element = kedge?.get?.('element')
  const trigger= reaction.get('trigger')
  const action = reaction.get('action')
  const option = reaction.get('option')
  // const queue = reaction.get('queue')
  if (trigger === "mutation") {
    if (!element || !trigger || !action || !option) throw("need all four parameters",reaction)
    const Observer = new MutationObserver(mutations => mutations.forEach(action) )
    Observer.observe(element,option)
    return reaction
  }
  if (trigger === "intersection") {
    if (!element || !trigger || !action || !option) throw("need all four parameters",reaction)
    const Observer = new IntersectionObserver(mutations => mutations.forEach(_=>action) )
    Observer.observe(element,option)
    return reaction
  }
  if (element && trigger && action && !option) {//throw("need all three parameters",reaction)
    element.addEventListener(trigger,action)
    return reaction
  }
  if (element && trigger && action && option) {//throw("need all three parameters",reaction)
    element.addEventListener(trigger,action,option)
    return reaction
  }
  if (!element && trigger && action && !option){ //throw("need all three parameters",reaction)
    window.addEventListener(trigger,action)
    return reaction
  }
  if (!element && trigger && action && option){ //throw("need all three parameters",reaction)
    window.addEventListener(trigger,action,option)
    return reaction
  }
  console.trace()
  throw ("failed check parameters")
}

Reaction.prototype.unactuate = function() {
  return unactuate(this)
}
export const unactuate = (reaction) => {
  const trigger = reaction.get('trigger')
  const action = reaction.get('action')
  removeEventListener(trigger, action)
  return reaction
}
