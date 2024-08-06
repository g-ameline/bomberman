
// BEHAVIOR | REACTION

export class behavior extends Map {
}

export const reaction = () => {
  const new_reaction = new behavior()
  return new_reaction
}
behavior.prototype.kedge = function(node) {
  return kedge(this,node)
}
export const kedge = (reaction,node) => {
  if (!(node instanceof Map)) throw new Error(`node,${node} (${typeof(node)}) should be a gost (node or sock ..) `)
  reaction.set('kedge',node)
  return reaction
}
behavior.prototype.trigger = function(happening) {
  return trigger(this,happening)
}
export const trigger = (reaction,happening) => {
  if (typeof happening !== 'string') throw new Error(`trigger must take a string and not that ${typeof(happening)}`)
  reaction.set('trigger',happening)
  return reaction
}
behavior.prototype.action = function(callback) {
  return action(this,callback)
}
export const action = (reaction,callback) => {
  if (typeof callback != 'function') throw("action ${callback} ${typeof(callback)} should be a function")
  reaction.set('action',callback)
  return reaction
}
behavior.prototype.option = function(config) {
  this.set('option',config)
  return this
}
// actuate , activate the behavior
behavior.prototype.actuate = function() {
  actuate(this)
}
// behavior.prototype.actuate = function() {
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
