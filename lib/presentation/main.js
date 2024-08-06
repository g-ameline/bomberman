  import * as n from './gost_framework/g_node.js';
  // import * as s from './gost_framework/g_sock.js';
  // import * as b from './gost_framework/g_reaction.js';
  import * as p from './gamepad.js';
  import {create_chat} from './chat.js';
  import {create_game_window} from './game.js';

export const create_chat_gamepads_display = 
  (chat_url,pad_url,display_url, parent = n.body()) => 
    {
      const main_frame = create_main_frame(parent)
      style_main_frame(main_frame)
      main_frame.essentiate().render()
      const chat_frame = create_chat(chat_url,main_frame)
      style_chat_frame(chat_frame)
      const pads_frame = create_all_pads(pad_url,main_frame)
      style_pads_frame(pads_frame)
      const display_frame = create_game_window(display_url,main_frame)
      style_display_frame(display_frame)
    }
const create_all_pads = (url,parent) => {
  const pad_column = p.create_button_container(parent)
  p.button_create_game_pad_wasd(url, pad_column)
  p.button_create_game_pad_tfgh(url, pad_column)
  p.button_create_game_pad_ijkl(url, pad_column)
  p.button_create_game_pad_arrows(url, pad_column)
  return pad_column
}
const create_main_frame = (parent = n.body()) => 
  parent.bear_child('div').id('main_frame')

const style_main_frame = (main_node) =>
  main_node
    .style('display','flex')
    .style('flex-direction' , 'row')
    .style('boxSizing','border-box')
    .style('border','solid lawngreen')
    .style('borderRadius','10px')

const style_chat_frame = (chat_node) =>
  chat_node.style('order',1)
const style_pads_frame = (pads_node) =>
  pads_node.style('order',3)
const style_display_frame = (display_node) =>
  display_node.style('order',2)
