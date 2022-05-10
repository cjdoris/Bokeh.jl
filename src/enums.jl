const ALIGN_ENUM = Set(["start", "center", "end"])

const ANCHOR_ENUM = Set([
    "top_left", "top_center", "top_right", "center_left", "center_center", "center_right",
    "bottom_left", "bottom_center", "bottom_right", "top", "left", "center", "right",
    "bottom",
])

const AUTO_ENUM = Set(["auto"])

const DIRECTION_ENUM = Set(["clock", "anticlock"])

const FONT_STYLE_ENUM = Set(["normal", "italic", "bold", "bold italic"])

const HATCH_PATTERN_ENUM = Set([
    "blank", "dot", "ring", "horizontal_line", "vertical_line", "cross", "horizontal_dash",
    "vertical_dash", "spiral", "right_diagonal_line", "left_diagonal_line",
    "diagonal_cross", "right_diagonal_dash", "left_diagonal_dash", "horizontal_wave",
    "vertical_wave", "criss_cross",
])

const HATCH_PATTERN_ABBREVIATION_ENUM = Set([
    " ", ".", "o", "-", "|", "+", "\"", ":", "@", "/", "\\","x", ",", "`", "v", ">", "*",
])

const HATCH_PATTERN_ALL_ENUM = union(HATCH_PATTERN_ENUM, HATCH_PATTERN_ABBREVIATION_ENUM)

const LATLON_ENUM = Set(["lat", "lon"])

const LEGEND_CLICK_POLICY_ENUM = Set(["none", "hide", "mute"])

const LEGEND_LOCATION_ENUM = ANCHOR_ENUM

const LOCATION_ENUM = Set(["above", "below", "left", "right"])

const MARKER_ENUM = Set([
    "asterisk", "circle", "circle_cross", "circle_dot", "circle_x", "circle_y", "cross",
    "dash", "diamond", "diamond_cross", "diamond_dot", "dot", "hex", "hex_dot",
    "inverted_triangle", "plus", "square", "square_cross", "square_dot", "square_pin",
    "square_x", "star", "star_dot", "triangle", "triangle_dot", "triangle_pin", "x", "y",
])

const NAMED_COLOR_ENUM = Set([
    "aliceblue", "antiquewhite", "aqua", "aquamarine", "azure", "beige", "bisque", "black",
    "blanchedalmond", "blue", "blueviolet", "brown", "burlywood", "cadetblue", "chartreuse",
    "chocolate", "coral", "cornflowerblue", "cornsilk", "crimson", "cyan", "darkblue",
    "darkcyan", "darkgoldenrod", "darkgray", "darkgreen", "darkgrey", "darkkhaki",
    "darkmagenta", "darkolivegreen", "darkorange", "darkorchid", "darkred", "darksalmon",
    "darkseagreen", "darkslateblue", "darkslategray", "darkslategrey", "darkturquoise",
    "darkviolet", "deeppink", "deepskyblue", "dimgray", "dimgrey", "dodgerblue",
    "firebrick", "floralwhite", "forestgreen", "fuchsia", "gainsboro", "ghostwhite", "gold",
    "goldenrod", "gray", "green", "greenyellow", "grey", "honeydew", "hotpink", "indianred",
    "indigo", "ivory", "khaki", "lavender", "lavenderblush", "lawngreen", "lemonchiffon",
    "lightblue", "lightcoral", "lightcyan", "lightgray", "lightgreen", "lightgrey",
    "lightpink", "lightsalmon", "lightseagreen", "lightskyblue", "lightslategray",
    "lightslategrey", "lightsteelblue", "lightyellow", "lime", "limegreen", "linen",
    "magenta", "maroon", "mediumaquamarine", "mediumblue", "mediumorchid", "mediumpurple",
    "mediumseagreen", "mediumslateblue", "mediumspringgreen", "mediumturquoise",
    "mediumvioletred", "midnightblue", "mintcream", "mistyrose", "moccasin", "navajowhite",
    "navy", "oldlace", "olive", "olivedrab", "orange", "orangered", "orchid",
    "palegoldenrod", "palegreen", "paleturquoise", "palevioletred", "papayawhip",
    "peachpuff", "peru", "pink", "plum", "powderblue", "purple", "rebeccapurple", "red",
    "rosybrown", "royalblue", "saddlebrown", "salmon", "sandybrown", "seagreen", "seashell",
    "sienna", "silver", "skyblue", "slateblue", "slategray", "slategrey", "snow",
    "springgreen", "steelblue", "tan", "teal", "thistle", "tomato", "turquoise", "violet",
    "wheat", "white", "whitesmoke", "yellow", "yellowgreen",
])

const NAMED_PALETTE_ENUM = Set(keys(PALETTES))

const NUMERAL_LANGUAGE_ENUM = Set([
    "be-nl", "chs", "cs", "da-dk", "de-ch", "de", "en", "en-gb", "es-ES", "es", "et", "fi",
    "fr-CA", "fr-ch", "fr", "hu", "it", "ja", "nl-nl", "pl", "pt-br", "pt-pt", "ru",
    "ru-UA", "sk", "th", "tr", "uk-UA",
])

const ORIENTATION_ENUM = Set(["horizontal", "vertical"])

const OUTPUT_BACKEND_ENUM = Set(["canvas", "svg", "webgl"])

const QUICK_TRACK_SIZING_ENUM = Set(["auto", "min", "fit", "max"])

const RENDER_LEVEL_ENUM = Set([
    "image", "underlay", "glyph", "guide", "annotation", "overlay",
])

const RESET_POLICY_ENUM = Set(["standard", "event_only"])

const ROUNDING_FUNCTION_ENUM = Set([
    "round", "nearest", "floor", "rounddown", "ceil", "roundup",
])

const SIZING_MODE_ENUM = Set([
    "stretch_width", "stretch_height", "stretch_both", "scale_width", "scale_height",
    "scale_both", "fixed",
])

const SIZING_POLICY_ENUM = Set(["fixed", "fit", "min", "max"])

const STEP_MODE_ENUM = Set(["before", "after", "center"])

const TEXT_ALIGN_ENUM = Set(["left", "right", "center"])

const TEXT_BASELINE_ENUM = Set([
    "top", "middle", "bottom", "alphabetic", "hanging", "ideographic",
])

const TICK_LABEL_ORIENTATION_ENUM = Set(["horizontal", "vertical", "parallel", "normal"])
