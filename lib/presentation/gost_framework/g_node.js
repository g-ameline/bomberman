// export default fresh_node
export class Node extends Map {}
export const node = (tag='div') => {
  const node = new Node()
  node.set('tag',tag)
  return node
}

export const body = () => node('body').set('element',document.body)

// ELEMENT
//   add
Node.prototype.element = function(dom_element) {
  return element(this,dom_element)
}

export const element = (a_node,dom_element)=> { 
  if (a_node.has('element')){console.warn("changing existing element ?")}
  a_node.set('element',dom_element)
  return a_node
}

Node.prototype.need_element = function() {
  return need_element(this)
}
export const need_element = (a_node) => {
  if (!(a_node.has('element'))) {console.trace();console.log(a_node);throw "missing element"}
  return a_node.get('element')
}
Node.prototype.stab_element = function() {
  return stab_element(this)
}
export const stab_element = (a_node) => {
  if (!(a_node.has('element'))) return null
  return a_node.get('element')
}
Node.prototype.has_element = function() {
  return has_element(this)
}
export const has_element = (a_node) => {
  return !!a_node.get('element')
}
export const get_element = (gost_or_element) => {
  if (gost_or_element instanceof Node){return gost_or_element}
  if (gost_or_element instanceof Map){
    if (!gost_or_element.has('a_node')){console.trace();throw ("there is no dom a_node attached to that gost a_node\n")} 
    return gost_or_element.get('a_node')
   }
  throw("what the hell did you pass as argument ?")
}

// id
//   add
Node.prototype.id = function(identifier) {
  return id(this,identifier)
}
export const id = (a_node,identifier)=>{
  if (a_node.has('id')){console.warn("changing existing id ${a_node.get('id')} for ${identifier} ?")}
  a_node.set('id',identifier)
  return a_node
}

//   render
Node.prototype.render_id = function(option='reset') {
  return render_id(this,option)
}
export const render_id = (a_node,option = 'reset')=>{
  if (option === 'reset') a_node.need_element().removeAttribute('id')
  if (!a_node.has('id')) return a_node
  a_node.get('element').id = a_node.get('id')
  return a_node
}

// TEXT
//   add
Node.prototype.text = function(content) {
  return text(this,content)
}
export const text = (a_node,content)=>{
  a_node.set('text',content)
  return a_node
}
//   render
Node.prototype.render_text = function() {
  return render_text(this)
}
export const render_text = (a_node)=>{
  if (a_node.has('text')) {
    a_node.get('element').textContent  = a_node.get('text')
  }
  return a_node
}
// get
Node.prototype.need_text = function() {
  return need_text(this)
}
export const need_text= (a_node) =>{
  if (!a_node.has('text')) throw("the a_node ${a_node.get('tag')} has no text")
  return a_node.get('text')
}
Node.prototype.stab_text = function() {
  return stab_text(this)
}
export const stab_text = (a_node) =>{
  if (!a_node.has('text')) return ''
  return a_node.get('text')
}
Node.prototype.get_text = function() {
  return get_text(this)
}
export const get_text = (a_node) =>{
  if (!a_node.has('text')) return null
  return a_node.get('text')
}

// ANY ATTRIBUTE
//   add
Node.prototype.other = function(attribute,value) {
  return other(this,attribute,value)
}
export const other = (a_node,attribute,value)=>{
    if (!a_node.has('others')) a_node.set('others',new Map())
    a_node.get('others').set(attribute,value)
    return a_node 
}
//   render
Node.prototype.render_other = function(attribute) {
  return render_other(this,attribute)
}
export const render_other = (a_node,attribute)=>{
  if (!a_node.has('others')) {throw("a_node has no ~others~ atrtbiutes")}
  if (!(a_node.get('others').has(attribute))) throw("a_node attribute is not there")
  const value =a_node.get('others').get(attribute)
  if (value || value === "") {
    a_node.get('element')[attribute] = value
  }
  return a_node
}

Node.prototype.render_others = function(option ='reset') {
  return render_others(this,option)
}
export const render_others = (a_node,option='reset')=>{
  if (option === 'reset') {
    a_node.get('others')?.forEach( (_,attribute) => a_node.need_element().removeAttribute(attribute))
  }
  a_node.get('others')?.forEach( (_,attribute) => {
    render_other(a_node,attribute)
  })
  return a_node
}
// CLASS
//  add
Node.prototype.class = function(className) {
  return add_class(this,className)
}
export const add_class = (a_node,className) => { 
  if (!a_node.has('classList')) a_node.set('classList',new Set())
  a_node.get('classList').add?.(className)
  return a_node 
}
// reset 
Node.prototype.reset_class = function(className='',option='try') {
  return reset_class(this,className,option)
}
export const reset_class = (a_node,className='',option='try')=> {
  if (className === '')  a_node.delete('classList')
  if (className !== '' && option==='must') a_node.get('classList').delete(className)
  if (className !== '' && option==='try') a_node.get('classList')?.delete(className)
  return a_node
}
//   render
Node.prototype.render_classes = function(reset ='reset') {
  return render_class(this,reset)
}
export const render_class = (a_node,reset='reset')=> {
  if (reset === 'reset') a_node.need_element().removeAttribute('class')
  if (!a_node.has('classList')) return a_node
  a_node.get('classList').forEach( (className)=>{ a_node.need_element().classList.add(className) })
  return a_node
}
// get
Node.prototype.has_class = function(className='') {
  return has_class(this,className)
}
export const has_class= (a_node,className='') => {  
  if (!a_node.has('classList')) return false
  if (!className) return a_node.get('classList')
  if (className) return a_node.get('classList').has(className) 
}
// STYLE
//  add
Node.prototype.style = function(property,value) {
  return style(this,property,value)
}
export const style= (a_node,property,value) => {  
    if (!a_node.has('style')) a_node.set('style',new Map())
  a_node.get('style').set(property,value) 
  return a_node 
}
//   render
Node.prototype.render_style = function(reset ='reset') {
  return render_style(this,reset)
}
export const render_style = (a_node,reset='reset')=>{
  if (reset == 'reset') a_node.need_element().removeAttribute('style')
  if (!a_node.has('style')) return a_node
  a_node.get('style').forEach?.( (v,p)=>{
    a_node.need_element().style[p]=v
  })
  return a_node
}
// get
Node.prototype.get_style = function(property) {
  return get_style(this,property)
}
export const get_style= (a_node,property) => {  
  return a_node.get('style')?.get(property) ?? null 
}
Node.prototype.stab_style = function(property) {
  return stab_style(this,property)
}
export const stab_style= (a_node,property) => {  
  return a_node.get('style')?.get(property) ?? ''
}
Node.prototype.need_style = function(property) {
  return need_style(this,property)
}
export const need_style= (a_node,property) => {  
  if (!a_node.has('style')) {console.trace();throw("there is no any style at all")}
  if (!a_node.get('style').has(property)) {console.trace();throw("this style is not there")}
  return a_node.get('style').get(property) 
}
// DATA
//  add
Node.prototype.data = function(property,value) {
  data(this,property,value)
}
export const data= (a_node,property,value) => {  
    if (!a_node.has('dataset')) a_node.set('dataset',new Map())
    a_node.get('dataset').set?.(property,value)
    return a_node 
}
// render
Node.prototype.render_data = function(reset='reset') {
  return render_data(this,reset)
}
export const render_data = (a_node,reset='reset')=>{
    const element = a_node.get('element')
    if (reset === 'reset')  element.removeAttribute('dataset')
    a_node.get('dataset')?.forEach( (v,p)=>{
      element.dataset.set(p,v)
    })
    return a_node
}

//  PARENT
Node.prototype.add_parent = function(parent) {
  return add_parent(this,parent)
}
export const add_parent = (a_node,parent)=>{
  a_node.set('parent',parent)
  if (!parent.has('children')) parent.set('children',new Set())
  parent.get('children').add(a_node)
  a_node.set('parent',parent)
  return a_node 
}

Node.prototype.bear_parent = function(parent) {
  return bear_parent(this,parent)
}
export const bear_parent = (a_node,parent)=>{
  a_node.set('parent',parent)
  if (!parent.has('children')) parent.set('children',new Set())
  parent.get('children').add(a_node)
  a_node.set('parent',parent)
  return a_node 
}
// CHILD
Node.prototype.add_child = function(child='div') {
  return add_child(this,child)
}
export const add_child = (a_node,child='div')=>{
  let child_a_node = ((tag_or_a_node)=>{
    if (typeof(tag_or_a_node) == 'string') return node(tag_or_a_node)
    if (child instanceof Map) return tag_or_a_node
  })(child)
  if (!a_node.has('children')) {a_node.set('children',new Set())}
  a_node.get('children').add(child_a_node)
  child_a_node.set('parent',a_node)
  return a_node
}

Node.prototype.bear_child = function(child='div') {
  return bear_child(this,child)
}
export const bear_child = (a_node,a_node_or_tag='div')=>{
  let child_a_node = ((tag_or_a_node)=>{
    if (!tag_or_a_node) return a_node()
    if (typeof(tag_or_a_node) == 'string') return node(tag_or_a_node)
    if (tag_or_a_node instanceof Map) return tag_or_a_node
  })(a_node_or_tag)
  if (!a_node.has('children')) {a_node.set('children',new Set())}
  a_node.get('children').add(child_a_node)
  child_a_node.set('parent',a_node)
  return child_a_node
}
// TREE MANAGEMENT


// essentiate ~ create dom tree eement
Node.prototype.essentiate= function(lineage= 'lineage', option='try') {
  return essentiate(this,lineage,option)
}
export const essentiate = (a_node,lineage= 'lineage', option='try')=>{
  if (a_node.get('tag') !== 'body'){
    if (option==='new') {
      if (a_node.has('element')) throw("gost tree already essentiated")
    }
    if (option==='reset') {
      if (a_node.has('element')) a_node.banish()
    }
    if (option==='try') {
      if (a_node.has('element')) {
        console.warn("gost tree already essentiated")
        return a_node
      }
    }
    a_node.set('element',document.createElement(a_node.get('tag')))
    a_node.get('parent').get('element').appendChild(a_node.get('element'))
  }
  if (a_node.get('tag') === 'body'){
    a_node.set('element',document.body)
  }
  if (lineage) 
    a_node.get('children')?.forEach(child=>child.essentiate(lineage,option))  
  return a_node
}

// remove essentiate a_node only
Node.prototype.banish= function(option='try') {
  return banish(this),option
}
export const banish= (a_node,option='try')=>{
  if (option==='must') {
    if (!a_node.has('element')) throw("try to banish an unessentiated a_node ${a_node}")
  }
  a_node.get('element').remove()
  a_node.delete('element')
  a_node.get('children')?.forEach(child=>child.banish(option)) 
  return a_node
}
// RENDER at tree scale
// render only the gost a_node
Node.prototype.render= function(lineage,reset,option) {
  render(this,lineage,reset,option)
  return this
}
export const render= (a_node,lineage='lineage',reset='reset',option='try')=>{
  if (option === 'need') a_node.need_element()
  if (option === 'try' && !a_node.has_element()) return a_node
  a_node.render_id(reset)
  a_node.render_text(reset)
  a_node.render_classes(reset)
  a_node.render_style(reset)
  a_node.render_data(reset)
  a_node.render_others(reset)
  if (lineage === 'lineage') a_node.get('children')?.forEach(child=>child.render(lineage,reset,option))
  return a_node
}

// essentiate and render
Node.prototype.spawn= function(lineage = 'lineage', option='try') {
  return spawn(this,lineage,option)
}
export const spawn= (a_node,lineage='reset',option='try')=>{
  a_node.essentiate(lineage, option).render(lineage,'no-reset')
  return a_node
}
Node.prototype.eradicate= function(option='') {
  eradicate(this,option)
}
export const eradicate = (a_node,option='') => {
  if (option !== 'only_children') {
    a_node.get('parent').get?.('children').delete?.(a_node)
    a_node.get('element')?.remove()
  }
  a_node.get('children')?.forEach((child)=>(child.eradicate()))
  if (option !== 'only_children') a_node.clear()
}

Node.prototype.locate= function(clue,lineage='lineage') {
  return locate(this,clue,lineage)
}
export const locate= (a_node,clue,lineage='lineage')=>{
  if (a_node.get('tag') === clue) return a_node
  if (a_node.get('id') === clue) return a_node
  if (a_node.get('classList')?.has(clue)) return a_node
  if (a_node.get('style')?.has(clue)) return a_node
  if (a_node.get('dataset')?.has(clue)) return a_node
  let result = null
  if (lineage=== 'lineage' && a_node.has('children')){
    for (const child of a_node.get('children')){
        result = (locate(child,clue,lineage));
        if (result) return result
    }
  }
  return null
}

Node.prototype.have= function(clue,lineage='lineage') {
  return have(this,clue,lineage)
}
export const have = (a_node,clue,lineage='lineage')=>{
  if (a_node.get('tag') === clue) return true
  if (a_node.get('id') === clue) return true
  if (a_node.get('classList')?.has(clue)) return true 
  if (a_node.get('style')?.has(clue)) return true 
  if (a_node.get('dataset')?.has(clue)) return true 
  if (a_node.get('others')?.has(clue)) return true 
  let result = false
  if (lineage=== 'lineage' && a_node.has('children')){
    for (const child of a_node.get('children')){
      result = (child.locate(clue,lineage));
      if (result) return result
    }
  }
  return false
}

Node.prototype.collect= function(clue,collectees = new Set()) {
  return collect(this,clue,collectees)
}
export const collect= (a_node,clue,collectees = new Set())=>{
  if (a_node.have(clue,'not recursive')) collectees.add(a_node)
  a_node.get('children')?.forEach?.(child => collect(child,clue,collectees))
  return collectees
}

