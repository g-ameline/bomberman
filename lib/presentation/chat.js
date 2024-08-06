  import * as n from './gost_framework/g_node.js';
  import * as s from './gost_framework/g_sock.js';
  import * as b from './gost_framework/g_reaction.js';

export const create_chat = (url, parent = n.body()) => {
  const frame_node = create_chat_frame(parent)
  init_chat_cycle(frame_node, url)
  frame_node.need_element().focus()
  return frame_node
}
const create_chat_frame = (parent = n.body()) => {
  const frame_node = parent.bear_child('div').id("frame")
  style_frame(frame_node) 
  frame_node.essentiate().render()
  return frame_node
}
const init_chat_cycle = (chat_frame, url) => {
  const enter_a_name_node = chat_frame.bear_child('input').id("your_name")
  style_enter_name(enter_a_name_node)
  enter_a_name_node
    .other('placeholder', "pick a name")
    .spawn()
  init_chat_reaction(chat_frame, enter_a_name_node, url).actuate()
}
const init_chat_reaction = (chat_frame, enter_a_name_node, url) =>
  b.reaction()
    .kedge(enter_a_name_node)
    .trigger('change')
    .option(true) // once
    .action(() => {
      console.log("chat is starting initalization")
      const [chat_box, socket, conversation_node, new_message_node] = create_chat_components(chat_frame,url)
      const name = enter_a_name_node.need_element().value
      enter_a_name_node.eradicate()
      chat_box.essentiate('lineage').render('lineage')
      send_name_when_socket_ready_reaction(name, socket).actuate()
      update_chat_from_socket_reaction(conversation_node, socket).actuate()
      send_message_to_socket_reaction(new_message_node, socket).actuate()
      close_chat_reaction(chat_frame, chat_box, socket).actuate()
    })
const create_chat_components = (chat_frame, url) => {
  const chat_box = chat_frame.bear_child('div').id("chat_box")
  style_chat_box(chat_box)
  // const socket = chat_box.bear_child(s.sock(url))
  const socket = s.sock(url).essentiate()
  chat_box.set('socket',socket)
  console.log(socket, socket.need_element)
  const conversation_node = chat_box.bear_child('div').id("conversation")
  style_conversation(conversation_node)
  const new_message_node = chat_box.bear_child('input')
    .id("new_message").other('placeholder', "type message here")
  style_new_message(new_message_node)
  return [chat_box, socket, conversation_node, new_message_node]
}
const send_name_when_socket_ready_reaction = (name, socket) =>
  b.reaction().kedge(socket).trigger('open')
    .action(() => {
      console.log("sending a name to server", name)
      socket.need_element().send(JSON.stringify({name: name}))
    })
const update_chat_from_socket_reaction = (conversation_node, socket) =>
  b.reaction()
    .kedge(socket)
    .trigger('message')
    .action((event) => {
      const note_obj = JSON.parse(event.data)
      const [name, message] = [note_obj.name, note_obj.message]
      add_new_missive_to_conversation(conversation_node, name, message)
      conversation_node.need_element().scrollTop = conversation_node.need_element().scrollHeight
    })
const send_message_to_socket_reaction = (new_message_node, socket) =>
  b.reaction()
    .kedge(new_message_node)
    .trigger('change')
    .action((event) => {
      const message = new_message_node.need_element().value
      new_message_node.other('value', '')
      const message_obj = JSON.stringify({message: message})
      socket.need_element().send(message_obj)
      new_message_node.render()
    })
const close_chat_reaction = (chat_frame, chat_box, socket) =>
  b.reaction()
    .kedge(socket)
    .trigger('close')
    .option(true) //once
    .action(() => {
      const url = chat_box.get('socket').get('url')
      console.log("websocket closed killing the chat")
      chat_box.eradicate()
      init_chat_cycle(chat_frame,url)
    })
const add_new_missive_to_conversation = (conversation_node, name, missive) => {
  const missive_node = conversation_node.bear_child().class('missive')
  const sender_node = missive_node.bear_child().text(name).class('sender')
  const message_node = missive_node.bear_child().text(missive).class('message')
  style_missive(missive_node);
  style_sender(sender_node);
  style_message(message_node);
  [missive_node,sender_node,message_node].map(node => node.essentiate().render())
}
// ------------ style -----------

const style_enter_name= (message_node) =>
  message_node
    .style('boxSizing','border-box')
    .style('border','solid peru')
    .style('borderRadius','10px')
    .style('clear','both')
    .style('textAlign','center')
    .style('verticalAlign', 'middle')
    .style('height','100%')
    .style('fontSize','xxx-large')

const style_frame = (frame_node) =>
  frame_node
    .style('position','relative')
    .style('boxSizing','border-box')
    .style('border','solid pink')
    .style('flexDirection', 'column')
    .style('padding','5px')
    // .style('width','550px')
    .style('width','fit-content')
    .style('display','flex')
    .style('rowGap', '10px')
    .style('columnGap', '10px')
    .style('width','300px')
    // .style('height','350px')
    .style('display','flex')
    .style('flex-grow','1')
    // .style('height','500px')
    .style('max-height','550px')

const style_chat_box = (frame_node) =>
  frame_node
    .style('boxSizing','border-box')
    .style('border','solid purple')
    .style('height','100%')

const style_conversation = (frame_node) =>
  frame_node
    .style('boxSizing','border-box')
    .style('border','solid blue')
    // .style('height','100%')
    // .style('width','500px')
    .style('height','80%')
    // .style('height','200px')
    .style('gap', '5px')
    // .style('flex',' 1 1 auto')
    // .style('overflow',' hidden')
    .style('overflowY', 'auto')
    .style('position',' relative')

const style_new_message = (new_message_node) =>
  new_message_node
    .style('boxSizing','border-box')
    .style('border','solid brown')
    .style('height','20%')
    .style('width','100%')

const style_missive= (new_message_node) =>
  new_message_node
    .style('flex','row')
    .style('display','flex')
    .style('columnGap', '5px')
    .style('overflowY', 'auto')
    .style('padding', '5px')

const style_sender = (sender_node) => {
  const border_color =  word_to_hsl_light(sender_node.get('text'))
  sender_node
    .style('boxSizing','border-box')
    .style('border',`solid ${border_color}`)
    .style('textAlign','center')
    .style('verticalAlign', 'middle')
    .style('padding','5px')
}

const style_message= (message_node) =>
  message_node
    .style('boxSizing','border-box')
    .style('border','solid grey')
    .style('borderRadius','10px')
    .style('clear','both')
    .style('whiteSpace','pre-line')
    .style('padding','5px')
    .style('verticalAlign', 'middle')

// ------------------- util ----------------------

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


