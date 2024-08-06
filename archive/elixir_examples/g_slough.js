export class slough extends Map {}

export const sock = (url="ws://"+window.location.host) => {
  const sock = new slough()
  sock.set('url',url)
  return sock
}

slough.prototype.essentiate= function() {
  if (!this.get('url')) throw new Error("cannot start websocketwithout url")
  if (this.has('element')) throw new Error("gost sock already has a websocketinitialized")
  const url = this.get('url')
  this.set('element',new WebSocket(url))
  return this
}
slough.prototype.render = function() {}
slough.prototype.banish = function() {
  this.get('element').close()
  this.delete('element')
  return this
}
slough.prototype.eradicate = function() {
  if (this.has('element')) {
    this.get('element').close()
    this.delete('element')
  }
  this.clear()
}

slough.prototype.need_element = function() {
  if (!(this.has('element'))) {console.trace();console.log(this);throw "missing element"}
  return this.get('element')
}