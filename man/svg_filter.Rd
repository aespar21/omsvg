% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filters.R
\name{svg_filter}
\alias{svg_filter}
\title{Build an SVG \verb{<filter>}}
\usage{
svg_filter(svg, id, width = NULL, height = NULL, filters = list())
}
\arguments{
\item{svg}{The \code{svg} object that is created using the \code{\link[=SVG]{SVG()}} function.}

\item{id}{The ID value to assign to the filter. This must be provided and it
should be unique among all \verb{<filter>} elements.}

\item{width, height}{The lengths of \code{width} and \code{height} define the extent of
the filter.}

\item{filters}{A list of \verb{filter_*()} function calls. Examples include
\code{\link[=filter_image]{filter_image()}} and \code{\link[=filter_gaussian_blur]{filter_gaussian_blur()}}.}
}
\description{
The \code{svg_filter()} let's us create a named \verb{<filter>} element that we can
apply to any SVG elements (such as shapes). We can bundle one or more filter
elements by supplying a list of \verb{filter_*()} calls to the \code{filters} argument.
}
\examples{
# Set up an `svg_filter()` (called
# `"blur"`) that has the blur effect
# (using the `filter_gaussian_blur()`
# function); have the ellipse element
# use the filter by referencing it
# by name via the `"filter"` attribute
SVG(width = 200, height = 100) \%>\%
  svg_filter(
    id = "blur",
    filters = list(
      filter_gaussian_blur(stdev = 2)
    )
  ) \%>\%
  svg_ellipse(
    x = 40, y = 40,
    width = 50, height = 30,
    attrs = svg_attrs_pres(
      fill = "green",
      filter = "blur"
    )
  )

}
