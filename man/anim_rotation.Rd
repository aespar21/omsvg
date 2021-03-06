% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/anim_rotation.R
\name{anim_rotation}
\alias{anim_rotation}
\title{Animate an element through rotation}
\usage{
anim_rotation(
  rotation = NULL,
  anchor = "center",
  easing_fn = NULL,
  initial = FALSE
)
}
\arguments{
\item{rotation}{The rotation value of the element at the keyframe time (given
as the LHS value in the \code{\link[=anims]{anims()}} call).}

\item{anchor}{The location of the element anchor about which rotation will
occur. By default, this is the keyword \code{"center"}.}

\item{easing_fn}{The timing or easing function to use for the animation. If
not provided, the \code{\link[=linear]{linear()}} timing function will be used (which is doesn't
use any easing in the animation, just a linear movement). The other timing
and easing functions are: \code{\link[=step_start]{step_start()}}, \code{\link[=step_end]{step_end()}}, \code{\link[=ease_in]{ease_in()}},
\code{\link[=ease_out]{ease_out()}}, and \code{\link[=ease_in_out]{ease_in_out()}}.}

\item{initial}{Should this rotation value be the initial rotation state of
the element? If so, use \code{TRUE} and any value provided to \code{rotation} will be
disregarded.}
}
\description{
Within an \code{\link[=anims]{anims()}} call, itself passed to any \code{anims} argument, the
\code{anim_rotation()} function can be used to express an animation where the
target element undergoes a rotation change with time.
}
\examples{
# This is a basic animation of an
# element's rotation state (moving to
# a new `rotation` value)
SVG(width = 300, height = 300) \%>\%
  svg_rect(
    x = 50, y = 50,
    width = 50, height = 50,
    attrs = svg_attrs_pres(
      stroke = "magenta",
      fill = "lightblue"
    ),
    anims = anims(
      2.0 ~ anim_rotation(rotation = 180)
    )
  )

}
