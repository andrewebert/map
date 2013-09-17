MARGIN_LEFT = 10
MARGIN_RIGHT = 10
MARGIN_TOP = 25+25+7+10
MARGIN_BOTTOM = 10

base_width = 1000
base_height = 506

width = window.innerWidth - MARGIN_LEFT - MARGIN_RIGHT
height = window.innerHeight - MARGIN_TOP - MARGIN_BOTTOM
base_scale = Math.min(width/base_width, height/base_height)

scale_step = 1.3
max_zoom = base_scale * Math.pow(scale_step, 8)
min_zoom = base_scale


calculate_scale = (x, y, direction, width, height, old_x, old_y, old_scale) ->
    amount = Math.pow(scale_step, direction)
    scale = old_scale * amount
    if (scale > max_zoom)
        scale = max_zoom
    else if (scale < min_zoom)
        scale = min_zoom
    scale_change = scale / old_scale

    x_trans = old_x - ((scale_change - 1) / scale) * x
    y_trans = old_y - ((scale_change - 1) / scale) * y

    [x_trans, y_trans] = adjust_trans(x_trans, y_trans, width, height, scale)
    return [x_trans, y_trans, scale]


adjust_trans = (x_trans_in, y_trans_in, width, height, scale) ->
    if (base_width * scale <= width)
        # scale <= 1
        max_x_trans = (width - base_width*scale) / (2*scale)
        min_x_trans = (width - base_width*scale) / (2*scale)
    else
        max_x_trans = 0
        min_x_trans = (width - base_width*scale) / scale
    if (base_height * scale <= height)
        # scale <= 1
        max_y_trans = (height - base_height*scale) / (2*scale)
        min_y_trans = (height - base_height*scale) / (2*scale)
    else
        max_y_trans = 0
        min_y_trans = (height - base_height*scale) / scale

    if x_trans_in > max_x_trans
        x_trans = max_x_trans
    else if x_trans_in < min_x_trans 
        x_trans= min_x_trans
    else
        x_trans = x_trans_in

    if y_trans_in > max_y_trans
        y_trans = max_y_trans
    else if y_trans_in < min_y_trans 
        y_trans= min_y_trans
    else
        y_trans = y_trans_in

    return [x_trans, y_trans]
