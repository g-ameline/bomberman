import * as n from "./gost_framework/g_node.js";

const scale = 50

export const unpix = (text) => text.slice(0,-2)
export const pix = (numb)  => (numb+'px')

export const absolute = (node) => node.style('position','absolute')

export const scaled_place= (unit) => ( (node,w,h) => place_node(node,w*unit,h*unit) )
export const place_node = (node,w,h) => 
	node.style('left',pix(w*0.5)).style('right',pix(-h*0.5))
export const place = scaled_place(scale)

export const scaled_translate = (unit) => ( (node,[x,y]) => translate_node(node,[x*unit,y*unit]) )
export const translate_node = (node,[x,y]) => node.style('translate',translation([x,y]))
export const translation = ([x,y]) => (pix(x)+' '+pix(y))
export const translate = scaled_translate(scale)

export const zygote_node = (entity_data) => {
  const entity_node = n.node('div')
  entity_node.id(entity_data.get('id')) 
  place(entity_node,1,1)
  const [x,y] = entity_data.get('position')
  translate(entity_node,[x,y])
  absolute(entity_node)
	return entity_node
}

export const refresh_position = (node,new_data) => {
	const old_position = node.get('position')
	const new_position = new_data.get('position')
	if (old_position == new_position) return new_state 
	translate(node,new_position).render_style('not reset')
}

export const make_it_a_square = (node) => 
	node.style('width',pix(scale))
	.style('height',pix(scale))

export const bomber_it = (node,bomber_data) => {
	detail_bomber(node,bomber_data)
	style_bomber(node)
}
export const detail_bomber = (node,data) => {
  const lives = data.get('lives')
  const grace = data.get('grace')>0 ? true : false
  const bombs = 'b'.repeat(data.get('bombs'))
  const info = `${lives} ${bombs}\n${grace}`
  node.text(info)
} 

const style_bomber = (node) => {
		make_it_a_square(node)
		const hsl = word_to_hsl_light(node.get('id'))
		node.style('backgroundColor',hsl)		
			.style('border','solid black')
			.style('boxSizing','border-box')
			.style('zIndex','9')
			.style('opacity', '0.8')
			.style('willChange', 'auto')
}

export const flame_it = (node,flame_data) => {
    const color = flame_data.get('incubation')> 0 ? 'red' : 'fuchsia'
    const orientation= flame_data.get('orientation')
		style_flame(node,orientation,color)
}
const style_flame = (node,orientation,color) =>{
	make_it_a_square(node)
	node.style('opacity', '0.7')
	const border_to_color = ( (orient) => {
		if (orient === 'still') return null  
		if (orient === 'up')	return 'borderBottom'
		if (orient === 'down') return 'borderTop'
		if (orient === 'left') return 'borderRight'
		if (orient === 'right') return 'borderLeft'
	})(orientation)
	const borders = new Set(['borderBottom','borderTop','borderRight','borderLeft'])
	borders.delete(border_to_color)
	borders.forEach(border => {node.style(border,pix(25)+ " solid " + 'coral')})
	if (border_to_color) node.style(border_to_color,pix(25) + " solid " + color)
	node.style('boxSizing','border-box')
}

export const block_it = (node) => {
		style_block(node)
}
const style_block = (node) =>{
	make_it_a_square(node)
	node.style('boxSizing','border-box')
		.style('backgroundColor','darkorange')
		.style('border','solid black')
}
export const wall_it = (node) => {
		style_wall(node)
}
const style_wall = (node) =>{
	make_it_a_square(node)
	node.style('boxSizing','border-box')
		.style('border','solid black')
		.style('backgroundColor','darkslateblue')
}
export const bomb_it = (node) => {
		style_bomb(node)
}
const style_bomb = (node) =>{
	make_it_a_square(node)
	node.style('border','solid black')
		.style('boxSizing','border-box')
		.style('backgroundColor','black')
		.style('borderRadius','50%')
		.style('zIndex','-1')
}

export const bonus_it = (node,data) => {
		style_bonus(node,data.get('bonus'))
}
const style_bonus = (node,perk) =>{
	make_it_a_square(node)
	const color = ( (b) => {
		if (b === 'speed') return 'orange'
		if (b === 'bombs') return 'yellow'
		if (b === 'range') return 'purple'
	})(perk)
	node.style('border','solid green')
		.style('boxSizing','border-box')
		.style('backgroundColor',color)
		.style('borderRadius','50%')
		.style('zIndex','-1')
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
