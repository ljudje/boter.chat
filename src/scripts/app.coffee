$ = require('jquery')

foundation = require('foundation')

# back_scroll = require('./back_scroll')
# equalizer = require('./equalizer')
external_links = require('./external_links')
bubbles = require('./bubbles')
background_color_test = require('./background_color_test')

# # # # # # # # # # # # # # #
# # # INIT  # # # # # # # # #
# # # # # # # # # # # # # # #

background_color_test.init()

$(document).foundation()

# back_scroll.init()

# equalizer.init()

external_links.init()

bubbles.init()
