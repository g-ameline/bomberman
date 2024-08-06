// export default fresh_node
export class crotch extends Map {}
export const node = (tag='div') => {
  const node = new crotch()
  node.set('tag',tag)
  return node
}

export const body = () => node('body').set('element',document.body)

// ELEMENT
//   add
crotch.prototype.element = function(dom_element) {
  return element(this,dom_element)
}

export const element = (node,dom_element)=> { 
  if (node.has('element')){console.warn("changing existing element ?")}
  node.set('element',dom_element)
  return node
}

crotch.prototype.need_element = function() {
  return need_element(this)
}
export const need_element = (node) => {
  if (!(node.has('element'))) {console.trace();console.log(node);throw "missing element"}
  return node.get('element')
}
crotch.prototype.stab_element = function() {
  return stab_element(this)
}
export const stab_element = (node) => {
  if (!(node.has('element'))) return null
  return node.get('element')
}
crotch.prototype.has_element = function() {
  return has_element(this)
}
export const has_element = (node) => {
  return !!node.get('element')
}
export const get_element = (gost_or_element) => {
  if (gost_or_element instanceof Node){return gost_or_element}
  if (gost_or_element instanceof Map){
    if (!gost_or_element.has('node')){console.trace();throw ("there is no dom node attached to that gost node\n")} 
    return gost_or_element.get('node')
   }
  throw("what the hell did you pass as argument ?")
}

// id
//   add
crotch.prototype.id = function(identifier) {
  return id(this,identifier)
}
export const id = (node,identifier)=>{
  if (node.has('id')){console.warn("changing existing id ${node.get('id')} for ${identifier} ?")}
  node.set('id',identifier)
  return node
}

//   render
crotch.prototype.render_id = function(option='reset') {
  return render_id(this,option)
}
export const render_id = (node,option = 'reset')=>{
  if (option === 'reset') node.need_element().removeAttribute('id')
  if (!node.has('id')) return node
  node.get('element').id = node.get('id')
  return node
}

// TEXT
//   add
crotch.prototype.text = function(content) {
  return text(this,content)
}
export const text = (node,content)=>{
  node.set('text',content)
  return node
}
//   render
crotch.prototype.render_text = function() {
  return render_text(this)
}
export const render_text = (node)=>{
  if (node.has('text')) {
    node.get('element').textContent  = node.get('text')
  }
  return node
}
// get
crotch.prototype.need_text = function() {
  return need_text(node)
}
export const need_text= (node) =>{
  if (!node.has('text')) throw("the node ${node.get('tag')} has no text")
  return node.get('text')
}
crotch.prototype.stab_text = function() {
  return stab_text(this)
}
export const stab_text = (node) =>{
  if (!node.has('text')) return ''
  return node.get('text')
}
crotch.prototype.get_text = function() {
  return get_text(this)
}
export const get_text = (node) =>{
  if (!node.has('text')) return null
  return node.get('text')
}

// ANY ATTRIBUTE
//   add
crotch.prototype.other = function(attribute,value) {
  return other(this,attribute,value)
}
export const other = (node,attribute,value)=>{
    if (!node.has('others')) node.set('others',new Map())
    node.get('others').set(attribute,value)
    return node 
}
//   render
crotch.prototype.render_other = function(attribute) {
  return render_other(this,attribute)
}
export const render_other = (node,attribute)=>{
  if (!node.has('others')) {throw("node has no ~others~ atrtbiutes")}
  if (!(node.get('others').has(attribute))) throw("node attribute is not there")
  const value =node.get('others').get(attribute)
  if (value || value === "") {
    node.get('element')[attribute] = value
  }
  return node
}

crotch.prototype.render_others = function(option ='reset') {
  return render_others(this,option)
}
export const render_others = (node,option='reset')=>{
  if (option === 'reset') {
    node.get('others')?.forEach( (_,attribute) => node.need_element().removeAttribute(attribute))
  }
  node.get('others')?.forEach( (_,attribute) => {
    render_other(node,attribute)
  })
  return node
}
// CLASS
//  add
crotch.prototype.class = function(className) {
  return add_class(this,className)
}
export const add_class = (node,className) => { 
  if (!node.has('classList')) node.set('classList',new Set())
  node.get('classList').add?.(className)
  return node 
}
// reset 
crotch.prototype.reset_class = function(className='',option='try') {
  return reset_class(this,className,option)
}
export const reset_class = (node,className='',option='try')=> {
  if (className === '')  node.delete('classList')
  if (className !== '' && option==='must') node.get('classList').delete(className)
  if (className !== '' && option==='try') node.get('classList')?.delete(className)
  return node
}
//   render
crotch.prototype.render_classes = function(reset ='reset') {
  return render_class(this,reset)
}
export const render_class = (node,reset='reset')=> {
  if (reset === 'reset') node.need_element().removeAttribute('class')
  if (!node.has('classList')) return node
  node.get('classList').forEach( (className)=>{ node.need_element().classList.add(className) })
  return node
}
// get
crotch.prototype.has_class = function(className='') {
  return has_class(this,className)
}
export const has_class= (node,className='') => {  
  if (!node.has('classList')) return false
  if (!className) return node.get('classList')
  if (className) return node.get('classList').has(className) 
}
// STYLE
//  add
crotch.prototype.style = function(property,value) {
  return style(this,property,value)
}
export const style= (a_node,property,value) => {  
    if (!a_node.has('style')) a_node.set('style',new Map())
  a_node.get('style').set(property,value) 
  return a_node 
}
//   render
crotch.prototype.render_style = function(reset ='reset') {
  return render_style(this,reset)
}
export const render_style = (node,reset='reset')=>{
  if (reset == 'reset') node.need_element().removeAttribute('style')
  if (!node.has('style')) return node
  node.get('style').forEach?.( (v,p)=>{
    node.need_element().style[p]=v
  })
  return node
}
// get
crotch.prototype.get_style = function(property) {
  return get_style(this,property)
}
export const get_style= (node,property) => {  
  return node.get('style')?.get(property) ?? null 
}
crotch.prototype.stab_style = function(property) {
  return stab_style(this,property)
}
export const stab_style= (node,property) => {  
  return node.get('style')?.get(property) ?? ''
}
crotch.prototype.need_style = function(property) {
  return need_style(this,property)
}
export const need_style= (node,property) => {  
  if (!node.has('style')) {console.trace();throw("there is no any style at all")}
  if (!node.get('style').has(property)) {console.trace();throw("this style is not there")}
  return node.get('style').get(property) 
}
// DATA
//  add
crotch.prototype.data = function(property,value) {
  data(this,property,value)
}
export const data= (node,property,value) => {  
    if (!node.has('dataset')) node.set('dataset',new Map())
    node.get('dataset').set?.(property,value)
    return node 
}
// render
crotch.prototype.render_data = function(reset='reset') {
  return render_data(this,reset)
}
export const render_data = (node,reset='reset')=>{
    const element = node.get('element')
    if (reset === 'reset')  element.removeAttribute('dataset')
    node.get('dataset')?.forEach( (v,p)=>{
      element.dataset.set(p,v)
    })
    return node
}

//  PARENT
crotch.prototype.add_parent = function(parent) {
  return add_parent(this,parent)
}
export const add_parent = (node,parent)=>{
  node.set('parent',parent)
  if (!parent.has('children')) parent.set('children',new Set())
  parent.get('children').add(node)
  node.set('parent',parent)
  return node 
}

crotch.prototype.bear_parent = function(parent) {
  return bear_parent(this,parent)
}
export const bear_parent = (node,parent)=>{
  node.set('parent',parent)
  if (!parent.has('children')) parent.set('children',new Set())
  parent.get('children').add(node)
  node.set('parent',parent)
  return node 
}
// CHILD
crotch.prototype.add_child = function(child='div') {
  return add_child(this,child)
}
export const add_child = (node,child='div')=>{
  let child_node = ((tag_or_node)=>{
    if (typeof(tag_or_node) == 'string') return node(tag_or_node)
    if (child instanceof Map) return tag_or_node
  })(child)
  if (!node.has('children')) {node.set('children',new Set())}
  node.get('children').add(child_node)
  child_node.set('parent',node)
  return node
}

crotch.prototype.bear_child = function(child='div') {
  return bear_child(this,child)
}
export const bear_child = (a_node,node_or_tag='div')=>{
  let child_node = ((tag_or_node)=>{
    if (!tag_or_node) return node()
    if (typeof(tag_or_node) == 'string') return node(tag_or_node)
    if (tag_or_node instanceof Map) return tag_or_node
  })(node_or_tag)
  if (!a_node.has('children')) {a_node.set('children',new Set())}
  a_node.get('children').add(child_node)
  child_node.set('parent',a_node)
  return child_node
}
// TREE MANAGEMENT


// essentiate ~ create dom tree eement
crotch.prototype.essentiate= function(lineage= 'lineage', option='try') {
  return essentiate(this,lineage,option)
}
export const essentiate = (node,lineage= 'lineage', option='try')=>{
  if (node.get('tag') !== 'body'){
    if (option==='new') {
      if (node.has('element')) throw("gost tree already essentiated")
    }
    if (option==='reset') {
      if (node.has('element')) node.banish()
    }
    if (option==='try') {
      if (node.has('element')) {
        console.warn("gost tree already essentiated")
        return node
      }
    }
    node.set('element',document.createElement(node.get('tag')))
    node.get('parent').get('element').appendChild(node.get('element'))
  }
  if (node.get('tag') === 'body'){
    node.set('element',document.body)
  }
  if (lineage) 
    node.get('children')?.forEach(child=>child.essentiate(lineage,option))  
  return node
}

// remove essentiate node only
crotch.prototype.banish= function(option='try') {
  return banish(this),option
}
export const banish= (node,option='try')=>{
  if (option==='must') {
    if (!node.has('element')) throw("try to banish an unessentiated node ${node}")
  }
  node.get('element').remove()
  node.delete('element')
  node.get('children')?.forEach(child=>child.banish(option)) 
  return node
}
// RENDER at tree scale
// render only the gost node
crotch.prototype.render= function(lineage,reset,option) {
  render(this,lineage,reset,option)
  return this
}
export const render= (node,lineage='lineage',reset='reset',option='try')=>{
  if (option === 'need') node.need_element()
  if (option === 'try' && !node.has_element()) return node
  node.render_id(reset)
  node.render_text(reset)
  node.render_classes(reset)
  node.render_style(reset)
  node.render_data(reset)
  node.render_others(reset)
  if (lineage === 'lineage') node.get('children')?.forEach(child=>child.render(lineage,reset,option))
  return node
}

// essentiate and render
crotch.prototype.spawn= function(lineage = 'lineage', option='try') {
  return spawn(this,lineage,option)
}
export const spawn= (node,lineage='reset',option='try')=>{
  node.essentiate(lineage, option).render(lineage,'no-reset')
  return node
}
crotch.prototype.eradicate= function(option='') {
  eradicate(this,option)
}
export const eradicate = (node,option='') => {
  if (option !== 'only_children') {
    node.get('parent').get?.('children').delete?.(node)
    node.get('element')?.remove()
  }
  node.get('children')?.forEach((child)=>(child.eradicate()))
  if (option !== 'only_children') node.clear()
}

crotch.prototype.locate= function(clue,lineage='lineage') {
  return locate(this,clue,lineage)
}
export const locate= (a_node,clue,lineage='lineage')=>{
  if (a_node.get('tag') === clue) return a_node
  if (a_node.get('id') === clue) return a_node
  if (a_node.get('classList')?.has(clue)) return a_node
  if (a_node.get('stye')?.has(clue)) return a_node
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

crotch.prototype.have= function(clue,lineage='lineage') {
  return have(this,clue,lineage)
}
export const have = (node,clue,lineage='lineage')=>{
  if (node.get('tag') === clue) return true
  if (node.get('id') === clue) return true
  if (node.get('classList')?.has(clue)) return true 
  if (node.get('stye')?.has(clue)) return true 
  if (node.get('dataset')?.has(clue)) return true 
  if (node.get('others')?.has(clue)) return true 
  let result = false
  if (lineage=== 'lineage' && node.has('children')){
    for (const child of node.get('children')){
      result = (child.locate(clue,lineage));
      if (result) return result
    }
  }
  return false
}

crotch.prototype.collect= function(clue,collectees = new Set()) {
  return collect(this,clue,collectees)
}
export const collect= (node,clue,collectees = new Set())=>{
  if (node.have(clue,'not recursive')) collectees.add(node)
  node.get('children')?.forEach?.(child => collect(child,clue,collectees))
  return collectees
}

