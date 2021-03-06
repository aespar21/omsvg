% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/elements.R
\name{svg_polyline}
\alias{svg_polyline}
\title{Addition of an \code{polyline} element}
\usage{
svg_polyline(
  svg,
  points,
  stroke = NULL,
  stroke_width = NULL,
  fill = NULL,
  opacity = NULL,
  attrs = list(),
  anims = list(),
  filters = list(),
  id = NULL
)
}
\arguments{
\item{svg}{The \code{svg} object that is created using the \code{\link[=SVG]{SVG()}} function.}

\item{points}{A numeric vector of points (with alternating values for \code{x} and
\code{y} positions) that define the polyline. This can also be a single-length
character vector that holds the formatted points string (space-separated
\code{x} and \code{y} values, and comma-separated points).}

\item{stroke}{The color of the stroke applied to the element (i.e., the
outline).}

\item{stroke_width}{The width of the stroke in units of pixels.}

\item{fill}{The fill color of the element.}

\item{opacity}{The opacity of the element. Must be a value in the
range of \code{0} to \code{1}.}

\item{attrs}{A presentation attribute list. The helper function
\code{\link[=svg_attrs_pres]{svg_attrs_pres()}} can help us easily generate this named list object. For the
most part, the list's names are the presentation attribute names and the
corresponding values are the matching attribute values.}

\item{anims}{An animation directive list for the element. This should be
structured using the \code{\link[=anims]{anims()}} function.}

\item{filters}{A filter directive list for the element. This is easily
created by using a list of \verb{filter_*()} functions (e.g.,
\code{list(filter_gaussian_blur(2), filter_drop_shadow(2, 2))}).}

\item{id}{An optional ID value to give to the built tag. This is useful for
modifying this element in a later function call or for interacting with
CSS.}
}
\description{
The \code{svg_polyline()} function adds a polyline to an \code{svg} object. The
polyline is drawn by connecting a series of points with straight lines. The
points can be provided as a vector that's exactly divisible by two, or, as a
formatted string that adheres to the specification of the \code{points} attribute
of the SVG \verb{<polyline>} tag. All point positions are in units of \code{px}.
}
\examples{
# Create an SVG with a single
# polyline element; here `points`
# is a numeric vector where pairs
# of values are the `x` and `y`
# point position
svg_1 <-
  SVG(width = 300, height = 300) \%>\%
    svg_polyline(
      points = c(
        10, 10, 15, 20, 20, 15, 25, 30, 30, 25,
        35, 40, 40, 35, 45, 50, 50, 45
      ),
      stroke = "blue"
    )

# Create the same SVG with a single
# polyline element; this time `points`
# is a formatted points string
svg_2 <-
  SVG(width = 300, height = 300) \%>\%
    svg_polyline(
      points =
        "10,10 15,20 20,15 25,30 30,25 35,40 40,35 45,50 50,45",
      stroke = "blue"
    )

}
