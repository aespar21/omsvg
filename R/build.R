build_svg <- function(svg) {

  # Create empty vector for SVG lines
  svg_lines <- c()

  # Extract the SVG properties and other stored information
  width  <- svg$width
  height <- svg$height
  title  <- svg$title
  viewbox <- svg$viewbox
  desc <- svg$desc
  incl_xmlns <- svg$incl_xmlns
  oneline <- svg$oneline
  elements <- svg$elements
  anim_iterations <- svg$anim_iterations

  # Get vector of `id`s
  ids <-
    elements %>%
    names() %>%
    vapply(
      FUN.VALUE = character(1),
      USE.NAMES = FALSE,
      function(x) ifelse(x == ":no_id:", NA_character_, x)
    )

  # Get vector of `type`s
  types <-
    elements %>%
    vapply(
      FUN.VALUE = character(1),
      USE.NAMES = FALSE,
      `[[`, 1
    )

  if (any_anims(elements = elements)) {

    anim_elements <- which_have_anims(elements = elements)

    keyframes <- c()

    # Get keyframes for each element with animations
    for (element_i in anim_elements) {

      elements <-
        process_animations_for_element(
          elements = elements,
          index = element_i,
          anim_iterations = anim_iterations
        )

      keyframes <- c(keyframes, elements[[element_i]]$anims_built$keyframes)
    }

    # Build all styles
    styles_str <- collapse_strings(keyframes, collapse = "\n")

    if (oneline) {

      built_styles <-
        styles_str %>%
        sass::sass(options = sass::sass_options(
          output_style = "compressed",
          indent_width = 2)
        ) %>%
        gsub("\n$", "", .) %>%
        as.character() %>%
        paste_left("<style>") %>%
        paste_right("</style>")

    } else {

      built_styles <-
        styles_str %>%
        sass::sass(options = sass::sass_options(
          output_style = "expanded",
          indent_width = 2)
        ) %>%
        as.character() %>%
        gsub("\n", "\n    ", .) %>%
        gsub("^", "    ", .) %>%
        paste_left("  <style>\n") %>%
        gsub("\n    $", "\n  </style>\n", .)
    }

  } else {

    built_styles <- c()
  }

  # If there are filters declared at the element level, promote
  # them to the SVG <defs> and create a unique ID to link to that
  if (any_filters(elements = elements)) {

    filter_elements <- which_have_filters(elements = elements)

    for (fe_index in filter_elements) {

      filters_at_index <- elements[[fe_index]]$filters

      id_val <- paste0("filter_", paste(sample(letters, 12), collapse = ""))

      svg <-
        svg %>%
        svg_filter(
          id = id_val,
          filters = filters_at_index
        )

      elements[[fe_index]][["filter"]] <-
        c(elements[[fe_index]][["filter"]],
          id_val %>% paste_left("url(#") %>% paste_right(")"))
    }
  }

  # Build all elements
  built_elements <-
    elements %>%
    vapply(
      FUN.VALUE = character(1),
      USE.NAMES = FALSE,
      function(x) build_element_tag(x)
    )

  width_attr <- create_dimension_attr("width", width)
  height_attr <- create_dimension_attr("height", height)
  viewbox_attr <- create_viewbox_attr(viewbox, width, height)
  xmlns_attr <- create_xmlns_attr(incl_xmlns)

  svg_o_tag <-
    paste(
      width_attr,
      height_attr,
      viewbox_attr,
      xmlns_attr
    ) %>%
    tidy_gsub("\\s*$", "") %>%
    paste_left("<svg ") %>%
    paste_right(">") %>%
    tidy_gsub("\\s+", " ")


  svg_lines <- c(svg_lines, svg_o_tag)

  if (!is.null(title)) {

    svg_title_tag <- paste0("<title>", title, "</title>")
    svg_lines <- c(svg_lines, svg_title_tag)
  }

  if (!is.null(desc)) {

    svg_desc_tag <- paste0("<desc>", desc, "</desc>")
    svg_lines <- c(svg_lines, svg_desc_tag)
  }

  # Build all defs and add to `svg_lines`
  if (length(svg$defs) > 0) {

    built_defs <-
      svg$defs %>%
      unlist() %>%
      paste(collapse = "\n") %>%
      paste_left("<defs>\n") %>%
      paste_right("\n</defs>")

    # Addition of built definitions
    svg_lines <- c(svg_lines, built_defs)
  }

  # Addition of built styles
  if (length(built_styles) > 0) {
    svg_lines <- c(svg_lines, built_styles)
  }

  # Addition of the built elements
  svg_lines <- c(svg_lines, built_elements)

  # Addition of closing <svg> tag
  svg_lines <- c(svg_lines, "</svg>")

  if (oneline) {

    svg_char_formatted <- svg_lines %>% paste(collapse = "")

  } else {

    svg_char_formatted <-
      svg_lines %>%
      paste(collapse = "\n") %>%
      xml2::read_xml() %>%
      as.character() %>%
      gsub("^<\\?xml.*?\\?>\\\n", "", .) %>%
      gsub("\\\n$", "", .)
  }

  svg_char_formatted
}

# Create an SVG dimension attribute (`height`, `width`)
create_dimension_attr <- function(attr_name, value) {

  if (is.null(value)) {
    return(NULL)
  }

  value %>%
    as.character() %>%
    paste_left("=\"") %>%
    paste_left(paste0(attr_name)) %>%
    paste_right("\"")
}

# Create the SVG `viewBox` attribute
create_viewbox_attr <- function(viewbox, width, height) {

  if (is.null(viewbox)) {
    return(NULL)
  } else if (isTRUE(viewbox)) {
    viewbox_dims <- c(0, 0, width, height) %>% paste(collapse = " ")
  } else {
    viewbox_dims <- viewbox %>% paste(collapse = " ")
  }

  viewbox_dims %>% paste_left("viewBox=\"") %>% paste_right("\"")
}

# Create the SVG `xmlns` attribute
create_xmlns_attr <- function(incl_xmlns) {

  if (!incl_xmlns) {
    return(NULL)
  }

  "xmlns=\"http://www.w3.org/2000/svg\""
}

non_attr_e_names <- function() {

  c(
    "type",
    "text",
    "attrs",
    "anims",
    "anims_built",
    "filters",
    "start",
    "tag",
    "path"
  )
}

build_element_tag <- function(element) {

  e <- element

  # Get the tag type
  type <- e$type

  # If the tag is already available, return it unchanged
  if (!is.na(e$tag)) {
    return(e$tag)
  }

  # Set default flags for tag
  open <- close <- TRUE
  self_close <- FALSE

  # Get the main attributes
  attrs_m <- e[names(e) %>% base::setdiff(non_attr_e_names())]

  # Get the extra attributes for the shape
  attrs_e <- e$attrs

  # Combine all attributes together
  attrs <- c(attrs_m, attrs_e)

  # Get the `inner` value for the `<text>` element, if available
  if (e$type == "text") {
    inner <- e$text
  } else {
    inner <- ""
  }

  attr_names <- names(attrs) %>% tidy_gsub("_", "-")

  attr_str <-
    seq(attrs) %>%
    lapply(function(x) build_attr(name = attr_names[x], value = attrs[[x]])) %>%
    unlist()

  # Set flags for `<g>` tags
  if (e$type == "g" & is.na(e$tag)) {
    close <- FALSE
  }

  # Set flags for elements with self-closing tags
  if (e$type %in% shape_types()) {
    self_close <- TRUE
  }

  built_tag <-
    build_tag(
      name = type,
      attrs = attr_str,
      inner = inner,
      open = open,
      close = close,
      self_close = self_close
    )

  if (!is.null(e$anims_built$style)) {

    styles <- rev(e$anims_built$style)

    for (style in styles) {

      built_tag <-
        built_tag %>%
        paste_left(style %>% paste_left("<g style=\"") %>% paste_right("\">\n")) %>%
        paste_right("\n</g>")
    }

    if (built_tag %>% tidy_grepl("anim_position")) {
      built_tag <- built_tag %>% tidy_gsub("x=.*? y=.*? ", "")
    }

    if (built_tag %>% tidy_grepl("anim_scale")) {
      built_tag <- built_tag %>% tidy_gsub("x=.*? y=.*? ", "")
    }

    if (built_tag %>% tidy_grepl("anim_rotation")) {
      built_tag <- built_tag %>% tidy_gsub("cx=.*? cy=.*? ", "")
    }
  }

  built_tag
}

build_attr <- function(name, value = NULL) {

  if (is.null(value)) {
    return(NULL)
  }

  paste0(name, "=", "\"", value, "\"")
}

build_tag <- function(name,
                      attrs,
                      inner = NULL,
                      open = TRUE,
                      close = TRUE,
                      self_close = FALSE) {

  tag_o <- paste0("<", name)
  tag_c <- paste0("</", name, ">")

  attrs_str <- paste(attrs, collapse = " ")

  if (is.null(inner)) {
    return(paste0(tag_o, " ", attrs_str, "/>"))
  }

  if (self_close) {
    built_tag <- paste0(tag_o, " ", attrs_str, "/>")
  } else if (open & close) {
    built_tag <- paste0(tag_o, " ", attrs_str, ">", inner, tag_c)
  } else if (open & !close) {
    built_tag <- paste0(tag_o, " ", attrs_str, ">")
  } else if (!open & close) {
    built_tag <- tag_c
  } else if (!open & !close) {
    built_tag <- inner
  }

  built_tag %>% tidy_gsub("\\s*>", ">")
}

# Determine if there are any filters
any_filters <- function(elements) {

  elements %>%
    vapply(
      FUN.VALUE = logical(1),
      USE.NAMES = FALSE,
      function(x) {length(x$filters) > 0}
    ) %>%
    any()
}

# Determine which elements have animations
which_have_filters <- function(elements) {

  elements %>%
    vapply(
      FUN.VALUE = logical(1),
      USE.NAMES = FALSE,
      function(x) {length(x$filters) > 0}
    ) %>%
    which()
}


