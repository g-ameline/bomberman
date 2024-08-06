import * as n from './gost_framework/g_node.js';
import * as s from './gost_framework/g_sock.js';
import * as r from './gost_framework/g_reaction.js';
import * as e from './entity.js';

export const create_game_window = (uri,parent = n.body()) => {
    console.log("creating game viewer socke at ${uri}")
    // create box/frame
    const game_frame = parent.bear_child('div').text("game_frame")
    style_frame(game_frame)
    game_frame .essentiate().render()
    // make websocket
    const socket = s.sock(uri).essentiate()
    const list_games = game_frame.bear_child('div')
    style_list(list_games)
    list_games .essentiate().render()
    const game_display = game_frame.bear_child('div').text("game_display")
    style_display(game_display)
    game_display.essentiate().render()
    const request_list_of_games_at_start =
        r.reaction()
            .kedge(socket)
            .trigger('open')
            .action( event => {
                console.log("socket, opened , sending 'list'")
                socket.need_element().send(JSON.stringify('list'))
            })
            // .actuate()
    const handle_message_from_server = 
        r.reaction()
            .kedge(socket)
            .trigger('message')
            .action( event => {
                const message_struct = eval(event.data) // unsafe but fast
                if (message_struct === null) {
                    game_display.eradicate('only_children')
                }
                if (message_struct instanceof Set) {
                    refresh_list(list_games, message_struct, socket, game_display)
                }
                if (message_struct instanceof Map) {
                    const game_pid = message_struct.get('pid')
                    if (game_pid != game_display.get('pid')) return
                    refresh_game(game_display,message_struct.get('game'))
                    do_after_next_frame( () => socket.need_element().send(JSON.stringify({'game':game_pid})) )
                }
            })
    
    request_list_of_games_at_start.actuate()
    handle_message_from_server.actuate()
    setInterval( ()=>socket.need_element().send(JSON.stringify('list')), 1000)
    return game_frame
}

// ---------------- LIST GAME ----------------

const refresh_list = (list_games_node,game_pids_set,socket_node, game_display) => {
    list_games_node.eradicate('only_children')
    game_pids_set.forEach(pid => add_a_game_pid(list_games_node,pid,socket_node,game_display))
}
const add_a_game_pid= (list,pid,socket_node,game_display) => {
    const game_pid_node = list.bear_child('div')
        .text(pid)
    style_pid(game_pid_node)
    game_pid_node .essentiate().render()
    ask_game_state(game_pid_node,socket_node,game_display).actuate() 
    game_pid_node
}
const ask_game_state = (game_pid_node,socket_node, game_display) =>
    r.reaction()
        .kedge(game_pid_node)
        .trigger('click')
        .action(event => {
            const game_pid = game_pid_node.need_text()
            socket_node.need_element().send(JSON.stringify({'game':game_pid}))
            game_display.set('pid',game_pid)
        })

// ---------------- GAME DISPLAY ----------------

const refresh_game= (game_display,state_map) => {
    state_map = keep_only_id_keys(state_map)
    game_display.get('children')?.forEach(node => refresh_node(node,state_map))
    state_map.forEach( (entity,_pid) => add_entity_to_display(game_display,entity))
}
const keep_only_id_keys = (data_map) => {
    data_map.forEach( (_value,key,map) => {
        if (typeof(key)==='number') return 
        if (typeof(key)==='string' && key[0] ==='#') return 
        if ( key[0].toLowerCase() !== key[0].toUpperCase() ) map.delete(key)
    } )
    return data_map
}
const refresh_node = (node,new_state) => {
    const id = node.get('id')
    // const kind = node.get('entity')
    if (new_state.has(id)) {
        const new_entity_data = new_state.get(id)
        const entity = new_entity_data.get('entity')
        if (entity === 'bomber') {
            e.refresh_position(node,new_entity_data)
            e.detail_bomber(node,new_entity_data) 
            node.render_style().render_text()
            // console.log(node.need_text())
            // console.log(node.need_element().textContent)
            // node.need_element().textContent = node.need_text()
        }
        if (entity === 'flame') {
            // e.refresh_position(node,new_entity_data)
            e.flame_it(node,new_entity_data)
            node.render_style()
        }
        // if (entity === 'block') 
        //     e.refresh_position(entity_node,entity_data) 
        // if (entity === 'wall') 
        //     e.refresh_position(entity_node,entity_data) 
        // if (entity === 'bomb') 
        //     e.refresh_position(entity_node,entity_data) 
            
        // const old_position = node.get('position')
        // const new_position = new_state.get(id).get('position')
        // if (old_position == new_position) return new_state 
        new_state.delete(id) // we are done with it 
        return new_state
    }
    if (!new_state.has(id)) node.eradicate()
    return new_state
}

const add_entity_to_display= (game_display,entity_data) => {
    const entity_node = game_display.bear_child(e.zygote_node(entity_data))
    const entity = entity_data.get('entity')
    if (entity === 'bomber')
        e.bomber_it(entity_node,entity_data)
    if (entity === 'flame')
        e.flame_it(entity_node,entity_data)
    if (entity === 'block')
        e.block_it(entity_node,entity_data)
    if (entity === 'wall')
        e.wall_it(entity_node,entity_data)
    if (entity === 'bomb')
        e.bomb_it(entity_node,entity_data)
    if (entity === 'bonus')
        e.bonus_it(entity_node,entity_data)
    entity_node.essentiate().render()
}

// ---------------- UTIL ----------------

const do_after_next_frame = (callback) => requestAnimationFrame(() => setTimeout(callback()))
// const do_after_next_frame = (callback) => setTimeout(()=>{console.log("sending");callback()},2000)

// ---------------- STYLE ----------------

const style_display= (display_node) =>
    display_node
        .style('boxSizing','border-box')
        .style('border','solid blue')
        .style('width','500px')
        .style('height','500px')
        // .style('flex','row')
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
    
const style_list = (list_games_node) =>
    list_games_node
        .style('boxSizing','border-box')
        .style('border','solid purple')
        .style('padding','5px')
        .style('width','500px')
        .style('flex','column')
        .style('display','flex')
        .style('flexDirection', 'row')
        .style('columnGap', '5px')
        // .style('width', '200px')

const style_pid = (pid_node) =>
    pid_node
    .style('backgroundColor','orange')
    .style('color','black')
    .style('border','solid black')
    .style('borderRadius','6px')
    // .style('height','40px')
    .style('lineHeight','1.15')
    .style('overflow','hidden')
    .style('position','relative')
    .style('textAlign','center')
    .style('verticalAlign', 'middle')
    // .style('width', '200px')
    .style('float', 'left')
