import * as n from './gost_framework/g_node.js';
import * as s from './gost_framework/g_sock.js';
import * as p from './gost_framework/g_pad.js';
import * as r from './gost_framework/g_reaction.js';

export const arrows_bindings = {
  left:'ArrowLeft', 
  right:'ArrowRight', 
  up:'ArrowUp', 
  down:'ArrowDown', 
  bomb:'ShiftRight', 
  start:'Enter', 
}
export const wasd_bindings = {
  left:'KeyA', 
  right:'KeyD', 
  up:'KeyW', 
  down:'KeyS', 
  bomb:'KeyE', 
  start:'KeyQ', 
}
export const tfgh_bindings = {
  left:'KeyF', 
  right:'KeyH', 
  up:'KeyT', 
  down:'KeyG', 
  bomb:'KeyY', 
  start:'KeyR', 
}
export const ijkl_bindings = {
  left:'KeyJ', 
  right:'KeyL', 
  up:'KeyI', 
  down:'KeyK', 
  bomb:'KeyU', 
  start:'KeyO', 
}

export const create_button_container = (parent = n.body()) =>
  parent.bear_child('div')
    .style('boxSizing','border-box')
    .style('border','solid purple')
    .style('padding','5px')
    .style('width','400px')
    .style('flex','column')
    .style('display','flex')
    .style('flexDirection', 'column')
    .style('rowGap', '10px')
    .essentiate()
    .render()

export const button_create_game_pad_arrows = (url, parent = n.body()) => {
  const button = parent
    .bear_child('button')
    .text("create a arraows-right_shift right_enter gamepad")
  const onclick = r.reaction()
    .kedge(button)
    .trigger('click')
    .action(event => 
      create_pad(parent,url,arrows_bindings)
    )
    style_button(button)
    button.essentiate().render()
    onclick.actuate()
}
export const button_create_game_pad_wasd = (url, parent = n.body()) => {
  const button = parent
    .bear_child('button')
    .text("create a WASD-QE gamepad")
  const onclick = r.reaction()
    .kedge(button)
    .trigger('click')
    .action(event => 
      create_pad(parent,url,wasd_bindings)
    )
    style_button(button)
    button.essentiate().render()
    onclick.actuate()
}
export const button_create_game_pad_tfgh = (url, parent = n.body()) => {
  const button = parent
    .bear_child('button')
    .text("create a TFGH-RY gamepad")
  const onclick = r.reaction()
    .kedge(button)
    .trigger('click')
    .action(event => 
      create_pad(parent,url,tfgh_bindings)
    )
    style_button(button)
    button.essentiate().render()
    onclick.actuate()
}
export const button_create_game_pad_ijkl = (url, parent = n.body()) => {
  const button = parent
    .bear_child('button')
    .text("create a IJKL-UO gamepad")
  const onclick = r.reaction()
    .kedge(button)
    .trigger('click')
    .action(event => 
      create_pad(parent,url,ijkl_bindings)
    )
    style_button(button)
    button.essentiate().render()
    onclick.actuate()
}

const style_button = (button_node) =>
  button_node
    .style('backgroundColor','black')
    .style('color','white')
    .style('borderRadius','6px')
    .style('height','40px')
    .style('lineHeight','1.15')
    .style('overflow','hidden')
    .style('position','relative')
    .style('textAlign','center')
    // .style('width', '200px')
    .style('float', 'left')

export const create_pad = (parent_node,url,bindings=arrows_bindings) => {
  desactivate_default_arrows() 
  // create gamepad container
  const frame_node = parent_node.bear_child().essentiate()
  p.style_frame(frame_node)
  frame_node.render()
  // let's create the gamepad logic
  const pad_node = frame_node.bear_child(p.pad())
    // configure inputs
  pad_node
    .left_key(bindings.left)
    .right_key(bindings.right)
    .up_key(bindings.up)
    .down_key(bindings.down)
    .bomb_key(bindings.bomb)
    .start_key(bindings.start)
    // configure web socket connection
    .sock(s.sock(url))
    // add buttons and reactions
    .acknowledge_message_from_server(frame_node)
    .shutdown_when_sock_close(frame_node)
    .make_botouns(frame_node)
    .make_delete_button(frame_node) 
    // behavior
    .update_direction()
    .update_bombing()
    .emit_start()
    // finalize
    .essentiate()
    .actuate()
}

const desactivate_default_arrows = () => 
  r.reaction()
    .option(false)
    .trigger('keydown')
    .action(event => {
      if(["Space","ArrowUp","ArrowDown","ArrowLeft","ArrowRight"].indexOf(event.code) > -1) {
          event.preventDefault();
      }
    })
    .actuate()

