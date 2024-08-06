import * as r from "./g_reaction.js";

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

Pad.prototype.start_key= function(keycode) {return start_key(this,keycode)}
export const start_key =(pad,keycode) => {
  pad.get('inputs').set('start',keycode)
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
Pad.prototype.send_command = function(command) {return send_command(this,command)}
export const send_command = (pad_node, command) => {
  pad_node.get('sock').need_element().send(pad.get(command))
  return pad
}
Pad.prototype.send_direction= function() {return send_direction(this)}
export const send_direction= (pad) => {
  pad.get('sock').need_element().send(pad.get_direction())
  return pad
}
Pad.prototype.send_bombing= function() {return send_bombing(this)}
export const send_bombing= (pad) => {
  pad.get('sock').need_element().send('bomb')
  return pad
}
Pad.prototype.send_start= function() {return send_start(this)}
export const send_start= (pad) => {
  pad.get('sock').need_element().send('start')
  return pad
}
// LISTEN TO KEYBOARD INPUTS AND SEND TO SERVER
Pad.prototype.update_direction = function() { return update_direction(this)}
export const update_direction = (pad) => {
  pad.get('behavior').add(
    r.reaction()
    .kedge(pad)
    .trigger('keydown')
    .action(event=>{
      pad.get('inputs').forEach((keycode,direction) => {
        if(!['left','right','up','down'].includes(direction)) return
        if (event.code !== keycode) return
        if (pad.get_direction() === direction) return
        pad.set_direction(direction).send_direction()
      })
    })
  )
  .add(
    r.reaction()
    .kedge(pad)
    .trigger('keyup')
    .action(event=>{
      pad.get('inputs').forEach((keycode,direction) => {
        if(!['left','right','up','down'].includes(direction)) return
        if (event.code !== keycode) return
        if (pad.get_direction() !== direction) return
        pad.set_direction('still').send_direction()
      })
    })
  )
  return pad
}
Pad.prototype.update_bombing= function() {return update_bombing(this)}
export const update_bombing = (pad) => {
  pad.get('behavior').add(
    r.reaction() // send bomb dropping command to server
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

Pad.prototype.emit_start= function() {return emit_start(this)}
export const emit_start = (pad) => {
  pad.get('behavior').add(
    r.reaction() // send start command to server
    .kedge(pad)
    .trigger('keydown')
    .action(event=>{
      const start_keycode = pad.get('inputs').get('start') 
      if (event.code !== start_keycode ) return
      console.log("will send start signal in ws ")        
      pad.send_start()
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
Pad.prototype.unactuate= function() {return unactuate(this)}
export const unactuate = (pad) => {
  pad.get('behavior')?.forEach(reaction=>reaction.unactuate()) 
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
Pad.prototype.eradicate= function() {return eradicate(this)}
export const eradicate = async (pad) => {
  pad.unactuate()
  pad.banish()
  pad.get('sock').eradicate()
  pad.clear()
}

Pad.prototype.make_botouns= function(frame_node) {
  return make_botouns(this,frame_node)
}
const make_botouns = (pad_node,frame_node) => {
  // loop into all commands and keycodes
  pad_node.get_inputs().forEach( (code,command)=> { 
    const botoun_node = frame_node.bear_child('div').text(command)
    style_button(botoun_node,command)
    botoun_node.essentiate().render()
    console.log("here")
    display_button_overing_behavior(pad_node,botoun_node,command)
    highlight_botoun_when_pressed(pad_node,botoun_node,command)       
  })
  return pad_node
}

export const display_button_overing_behavior = (pad_node,botoun_node,command) =>{
  const update_keycode = (event) => {
    console.log("udpate keycode !!!!!")
    pad_node.get_inputs().set(command,event.code)
    botoun_node.text(event.code).render()
  }
  const keycode = pad_node.get_inputs().get(command)
  const display_code_over_reaction = 
    r.reaction()
      .kedge(botoun_node)
      .trigger('mouseenter')
      .action( ()=> {
        botoun_node.text(pad_node.get_inputs().get(command))
        botoun_node.class('hovered').render()
        console.log("hovered",command,keycode)
          botoun_node.need_element().focus()
        // add nested event that change command's keycode on press
          r.reaction()
          .trigger('keydown')
          .action(update_keycode)
          .actuate()
      } )
  pad_node.get('behavior').add(display_code_over_reaction )
      // .actuate()
  const dipslay_command_rest_reaction = 
    r.reaction()
    .kedge(botoun_node)
    .trigger('mouseleave')
    .action( ()=> {
      botoun_node.text(command)
      botoun_node.reset_class().render()
      removeEventListener('keydown',update_keycode)
    } )
    pad_node.get('behavior').add(dipslay_command_rest_reaction )
    // .actuate()
}

const highlight_botoun_when_pressed = (pad_node,botoun_node,command) =>{
    botoun_node.need_element()
  // add nested event that change command's keycode on press
  pad_node.get('behavior').add(
    r.reaction()
    .trigger('keydown')
    .action(event => {
      const keycode = pad_node.get_inputs().get(command)
      if (keycode === event.code) botoun_node.style('color','red')
      botoun_node.render()
    })
  )
  pad_node.get('behavior').add(
    r.reaction()
    .trigger('keyup')
    .action(event => {
      const keycode = pad_node.get_inputs().get(command)
      if (keycode === event.code) botoun_node.style('color','black')
      botoun_node.render()
    })
  )
}

Pad.prototype.shutdown_when_sock_close = function(frame_node) {
  return shutdown_when_sock_close(this, frame_node )
}
export const shutdown_when_sock_close = (pad_node , frame_node) => {
  pad_node.get('behavior').add(
    r.reaction()
        .kedge(pad_node.get_sock())
        .trigger('close')
        .action( event => {
          pad_node.eradicate()
          frame_node.eradicate()
        })
    ) 
  return pad_node
}

Pad.prototype.make_delete_button = function(frame_node) {
  return make_delete_button(this, frame_node)
}
const make_delete_button = (pad_node, frame_node) => {
  const delete_node = frame_node.bear_child('div')
  pad_node.shutdown_when_pressed(frame_node,delete_node)
  delete_node.style()
    // .text('X')
    .style('position', 'absolute')
    // .style('fontSize','xx-small')
  	.style('border','solid white')
    .style('height', '9px')
    .style('width', '9px')
    // .style('textAlign','center')
    // .style('margin','zero')
    // .style('padding','zero')
    .style('borderRadius','50%')
  	.style('backgroundColor', 'red')

    // .style('position', 'relative')
    // .style('left', '2px')
    .style('zIndex', '100')
  delete_node.essentiate().render()
  return pad_node
}

const make_pid_mark= (pad_node, frame_node,pid) => {
  const delete_node = frame_node.bear_child('div')
  pad_node.shutdown_when_pressed(frame_node,delete_node)
  delete_node.style()
    // .style('float', 'right')
    .style('position', 'absolute')
    .style('fontSize','small')
  	.style('border','solid black')
    // .style('height', '9px')
    // .style('width', '9px')
    .style('textAlign','center')
    // .style('margin','zero')
    // .style('padding','zero')
    .style('bottom', '3px')
    .style('left', '3px')
    .style('borderRadius','20%')
  	.style('backgroundColor', 'white')
    // .style('position', 'relative')
    // .style('right', '2px')
    .style('zIndex', '100')
    .text(pid)
  delete_node.essentiate().render()
  return pad_node
}

Pad.prototype.shutdown_when_pressed = function(frame_node,delete_node) {
  return shutdown_when_pressed(this, frame_node ,delete_node)
}
export const shutdown_when_pressed = (pad_node , frame_node, delete_node) => {
  pad_node.get('behavior').add(
    r.reaction()
        .kedge(delete_node)
        .trigger('click')
        .action( event => {
          pad_node.eradicate()
          frame_node.eradicate()
        })
    ) 
  return pad_node
}

Pad.prototype.acknowledge_message_from_server = function(frame_node) {
  return acknowledge_message_from_server(this, frame_node)
}
export const acknowledge_message_from_server = (pad_node, frame_node ) =>{
  console.log("creating reaction message ws")
  pad_node.get('behavior').add(
    r.reaction()
        .kedge(pad_node.get_sock())
        .trigger('message')
        .action( event => {
          const message = event.data
          console.log("message :  ", message)
          if (message === 'lost') {
            frame_node
            	.style('border','thick dotted grey')
              .render_style()
          }
          if (message === 'victory') {
            frame_node
            	.style('border','thick double green')
              .render_style()
          } 
          if (message [0] === '#') { // means this is our pid
            const color = word_to_hsl_light(message) 
            make_pid_mark(pad_node, frame_node,message)
            frame_node
            	.style('backgroundColor', color)
              .render_style()
          }
        })
  )
  return pad_node
}

export const style_frame = (frame_node) => frame_node
  .style('display','grid')
  .style('row-gap','5px')
  .style('column-gap','30px')
	.style('boxSizing','border-box')
	.style('border','solid black')
	// .style('width','200px')
	.style('height','70px')
  .style('padding', "5px")
	// .style('justifyContent','space-evenly')
	.style('justifyContent','flex-end')
	.style('alignContent','space-evenly')
  .style('position','relative')

const style_button = (button_node,command) => {
  const [col,row] = ( (com)=> {
    if (com === 'up') return ['2','1']
    if (com === 'left') return ['1','2']
    if (com === 'down') return ['2','2']
    if (com === 'right') return ['3','2']
    if (com === 'start') return ['1','1']
    if (com === 'bomb') return ['3','1']
    console.warn(`should not happen ${com}`)
  }) (command)
  button_node
    .style('gridColumn', col )
    .style('gridRow', row )
  	.style('border','solid black')
  	.style('boxSizing','border-box')
  	.style('backgroundColor','cornsilk')
  	.style('justifySelf','stretch')
  	.style('textAlign','center')
  	.style('borderRadius','10%')
}
export const word_to_hsl = (name,saturation,lightness) => {
    if (name !== ''){
        const number = [...name]
            .map(char => char.charCodeAt(0))
            .reduce((current, previous) => previous*(1+current) + current)
            % 360
        let hue = number.toString()
        return `hsl(${hue},${saturation}%,${lightness}%)`
    }
    return "hsl(0),(100%),(100%)"
}
export const word_to_hsl_light = (word) => {
    return word_to_hsl(word,'100','50')
}

