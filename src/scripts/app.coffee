$ = require('jquery')

foundation = require('foundation')

equalizer = require('./equalizer')
# responsive_images = require('./responsive_images')
external_links = require('./external_links')
# back_scroll = require('./back_scroll')

# # # # # # # # # # # # # # #
# # # INIT  # # # # # # # # #
# # # # # # # # # # # # # # #

$(document).foundation()

equalizer.init()

# responsive_images.init()

external_links.init()

# back_scroll.init()
