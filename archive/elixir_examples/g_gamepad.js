import * as b from "./g_behavior.js";

// class
export class Pad extends Map {}
// creation
export const pad = () => {
  const pad = new Pad()
    pad.set('direction','still')
    pad.set('inputs',new Map())
    pad.set('behavior',new Set())
  return pad
}
// add a web socket as property
Pad.prototype.sock= function(socket) {return sock(this,socket)}
export const sock =(pad,sock) => {
  pad.set('sock',sock)
  return pad 
}
Pad.prototype.get_sock = function() {return get_sock(this)}
export const get_sock =(pad) => pad.get('sock')

Pad.prototype.get_inputs = function() {return get_inputs(this)}
export const get_inputs =(pad) => pad.get('inputs')
//  SETUP KEYCODES FOR EACH INPUTS
Pad.prototype.input= function(command,keycode) {return input(this,command,keycode)}
export const input =(pad,command,keycode) => {
  pad.get('inputs').set(command,keycode)
  return pad 
}
Pad.prototype.left_key= function(keycode) {return left_key(this,keycode)}
export const left_key =(pad,keycode) => {
  pad.get('inputs').set('left',keycode)
  return pad 
}
Pad.prototype.right_key= function(keycode) {return right_key(this,keycode)}
export const right_key =(pad,keycode) => {
  pad.get('inputs').set('right',keycode)
  return pad 
}
Pad.prototype.up_key= function(keycode) {return up_key(this,keycode)}
export const up_key =(pad,keycode) => {
  pad.get('inputs').set('up',keycode)
  return pad 
}
Pad.prototype.down_key= function(keycode) {return down_key(this,keycode)}
export const down_key =(pad,keycode) => {
  pad.get('inputs').set('down',keycode)
  return pad 
}
Pad.prototype.bomb_key= function(keycode) {return bomb_key(this,keycode)}
export const bomb_key =(pad,keycode) => {
  pad.get('inputs').set('bomb',keycode)
  return pad 
}

// COMMAND STATE MANAGEMENT
Pad.prototype.get_direction = function() {return get_direction(this)}
export const get_direction =(pad) => pad.get('direction')
  // functions used by events to update command state through keyboard inputs
Pad.prototype.set_direction = function(direction) {return set_direction(this,direction)}
export const set_direction = (pad,new_direction) => {
    if (!['left','right','up','down','still'].includes(new_direction)) throw(` ${new_direction} not a valid direction`)
    if (pad.get_direction() !== new_direction) pad.set('direction',new_direction)
    return pad 
  }
// helpers to transmit state through websocket
Pad.prototype.send_direction= function() {return send_direction(this)}
export const send_direction= (pad) => {
  pad.get('sock').need_element().send(pad.get_direction())
  return pad
}
Pad.prototype.send_bombing= function() {return send_bombing(this)}
export const send_bombing= (pad) => {
  pad.get('sock').need_element().send('bombing')
  return pad
}
// LISTEN TO KEYBOARD INPUTS AND SEND TO SERVER
Pad.prototype.update_direction = function() { return update_direction(this)}
export const update_direction = (pad) => {
  pad.get('behavior').add(
    b.reaction()
    .kedge(pad)
    .trigger('keydown')
    .action(event=>{
      pad.get('inputs').forEach((keycode,direction) => {
        if(!['left','right','up','down'].includes(direction)) return
        if (event.code !== keycode) return
        if (pad.get_direction() === direction) return
        console.log("will reset direction in ws ",direction)
        pad.set_direction(direction).send_direction()
      })
    })
  )
  .add(
    b.reaction()
    .kedge(pad)
    .trigger('keyup')
    .action(event=>{
      pad.get('inputs').forEach((keycode,direction) => {
        if(!['left','right','up','down'].includes(direction)) return
        if (event.code !== keycode) return
        if (pad.get_direction() !== direction) return
        console.log("will reset direction in ws ",'still')
        pad.set_direction('still').send_direction()
      })
    })
  )
  return pad
}
Pad.prototype.update_bombing= function() {return update_bombing(this)}
export const update_bombing = (pad) => {
  pad.get('behavior').add(
    b.reaction() // send bomb dropping command to server
    .kedge(pad)
    .trigger('keydown')
    .action(event=>{
      const bomb_keycode = pad.get('inputs').get('bomb') 
      if (event.code !== bomb_keycode ) return
      console.log("will ask to drop a bomb in ws ")        
      pad.send_bombing()
    })
  )
  return pad
}
// ACTUATE ALL REACTIONS
Pad.prototype.actuate= function() {return actuate(this)}
export const actuate = (pad) => {
  pad.get('behavior').forEach(reaction=>reaction.actuate()) 
  return pad
}
// open ws if not already
Pad.prototype.essentiate= function() {return essentiate(this)}
export const essentiate = (pad,option="lineage") => {
  if (option === 'lineage') pad.get('sock').essentiate()
  // add option to create rendered buttons that will decide of the keyboard input for each command
  return pad
}
Pad.prototype.banish= function() {return banish(this)}
export const banish = async (pad) => {
  pad.get('sock').banish()
  return pad
}


Pad.prototype.make_botouns= function(parent_node) {return make_botouns(this,parent_node)}
const make_botouns = (pad_node,parent_node) =>{
  // loop into all commands and keycodes
  pad_node.get_inputs().forEach( (code,command)=> { 
    const botoun_node = parent_node.bear_child('div')
    .text(command)
    .essentiate().render()
    display_button_overing_behavior(pad_node,botoun_node,command)
    highlight_botoun_when_pressed(pad_node,botoun_node,command)       
    // change_keycode_overing_behavior(pad_node,botoun_node,command)
    // botoun | parent node | code | command
  })
}

export const display_button_overing_behavior = (pad_node,botoun_node,command) =>{
  const update_keycode = (event) =>{
    console.log('changing')
    console.log("keycode before",pad_node.get_inputs().get(command))
    pad_node.get_inputs().set(command,event.code)
    console.log("keycode after",pad_node.get_inputs().get(command))
    botoun_node.text(event.code).render()
  }
  const keycode = pad_node.get_inputs().get(command)
  const display_code_over_reaction = 
    b.reaction()
    .kedge(botoun_node)
    .trigger('mouseenter')
    .action( ()=> {
      botoun_node.text(pad_node.get_inputs().get(command))
      botoun_node.class('hovered').render()
      console.log("hovered",command,keycode)
        botoun_node.need_element().focus()
      // add nested event that change command's keycode on press
        b.reaction()
        .trigger('keydown')
        .action(update_keycode)
        .actuate()
    } )
    .actuate()
  const dipslay_command_rest_reaction = 
    b.reaction()
    .kedge(botoun_node)
    .trigger('mouseleave')
    .action( ()=> {
      botoun_node.text(command)
      botoun_node.reset_class().render()
      removeEventListener('keydown',update_keycode)
    } )
    .actuate()
}

const highlight_botoun_when_pressed = (pad_node,botoun_node,command) =>{
    botoun_node.need_element()
  // add nested event that change command's keycode on press
    b.reaction()
    .trigger('keydown')
    .action(event => {
      const keycode = pad_node.get_inputs().get(command)
      if (keycode === event.code) botoun_node.style('color','red')
      botoun_node.render()
    })
    .actuate()
    b.reaction()
    .trigger('keyup')
    .action(event => {
      const keycode = pad_node.get_inputs().get(command)
      if (keycode === event.code) botoun_node.style('color','black')
      botoun_node.render()
    })
    .actuate()
}
// export const change_keycode_overing_behavior = (pad_node,botoun_node,command) =>{
//   // take registered commmand and keycode
//   const change_code_over_pressed_reaction = 
//     b.reaction()
//     .kedge(botoun_node)
//     .trigger('keydown')
//     .action( (event)=> {
//       console.log('changing')
//       if (!botoun_node.get('classList').has('hovered')) return
//       console.log('changing')
//       pad_node.inputs(command,event.code)
//       botoun_node.text(event.code).render()
//     } )
//   change_code_over_pressed_reaction.actuate()
//   // return change_code_over_pressed_reaction
// }

