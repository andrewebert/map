### INITIALIZE DATA ###

formals = {}
paths = {}

p = {
    zoom: 1.0,
    width: base_scale*base_width,
    height: base_scale*base_height,
    x_trans: 0,
    y_trans: 0,
    scale: base_scale
}

drag_data = {}

### DEFINE HANDLERS ###

hover_in = (e) -> #console.log("hover in #{formals[e.srcElement.id]}")
hover_out = (e) -> #console.log("hover out #{formals[e.srcElement.id]}")

set_transform = ->
    w.transform("scale(#{p.scale}) translate(#{p.x_trans}, #{p.y_trans})")

zoom_handler = (e) ->
    if e.wheelDelta?
        direction = if e.wheelDelta > 0 then 1 else -1
    else if e.detail?
        direction = if e.detail > 0 then -1 else 1
    else
        return

    x = e.layerX ? e.originalEvent.layerX
    y = e.layerY ? e.originalEvent.layerY

    console.log("zoom zoom zoom #{direction} #{x} #{y}")

    [p.x_trans, p.y_trans, p.scale] = calculate_scale(x, y, direction, p.width, p.height,
        p.x_trans, p.y_trans, p.scale)

    set_transform()

    e.preventDefault()
    return false

grab = (e) ->
    drag_data.grab_x = e.pageX
    drag_data.grab_y = e.pageY
    drag_data.last_x = e.pageX
    drag_data.last_y = e.pageY

drag = (e) ->
    drag_data.drag_amount = 0
    if drag_data.last_x? and drag_data.last_y?
        x = e.pageX
        y = e.pageY
        x_trans = p.x_trans + (x - drag_data.last_x)/p.scale
        y_trans = p.y_trans + (y - drag_data.last_y)/p.scale
        [p.x_trans, p.y_trans] = adjust_trans(x_trans, y_trans, p.width, p.height, p.scale)
        drag_data.last_x = x
        drag_data.last_y = y
        set_transform()

rc = 0
release = () ->
    drag_data.drag_amount = Math.max(
        Math.abs(drag_data.last_x - drag_data.grab_x),
        Math.abs(drag_data.last_y - drag_data.grab_y))
    drag_data.last_x = undefined
    drag_data.last_y = undefined
    console.log("release #{rc += 1}")


### INITIALIZE WORLD ###

s = Snap("#world")
w = s.g().attr(id: "w")

for country_code, data of initial_countries
    formals[country_code] = data.formal
    path = s.path("#{data.d}")
        .attr(id: country_code, class: fills[country_code])
        .hover(hover_in, hover_out)
    w.add(path)
    paths[country_code] = path

s.attr(width: p.width, height: p.height)
set_transform()

### SET HANDLERS ###

s.mousedown(grab)
s.mousemove(drag)

world = document.getElementById("world")
if world.onmousewheel != undefined
    world.onmousewheel = zoom_handler
else
    world.addEventListener("mousewheel", zoom_handler, false)
    # Firefox
    world.addEventListener("DOMMouseScroll", zoom_handler, false)

everything = document.getElementById("everything")
if everything.onmouseup != undefined
    everything.onmouseup = release
else
    everything.addEventListener("mouseup", release, false)
