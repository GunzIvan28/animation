

##' Gradient Descent Algorithm for the 2D Case
##' This function has provided a visual illustration for the process of
##' minimizing a real-valued function through Gradient Descent Algorithm.
##' 
##' Gradient descent is an optimization algorithm. To find a local minimum of a
##' function using gradient descent, one takes steps proportional to the
##' negative of the gradient (or the approximate gradient) of the function at
##' the current point. If instead one takes steps proportional to the gradient,
##' one approaches a local maximum of that function; the procedure is then
##' known as gradient ascent.
##' 
##' The arrows are indicating the result of iterations and the process of
##' minimization; they will go to a local minimum in the end if the maximum
##' number of iterations (\code{nmax} in \code{control}) has not been reached.
##' 
##' @param FUN the objective function to be minimized; contains only two
##'   independent variables (variable names do not need to be 'x' and 'y')
##' @param rg ranges for independent variables to plot contours; in a
##'   \code{c(x0, y0, x1, y1)} form
##' @param init starting values
##' @param gamma size of a step
##' @param tol tolerance to stop the iterations, i.e. the minimum difference
##'   between \eqn{F(x_i)}{F(x[i])} and \eqn{F(x_{i+1})}{F(x[i+1])}
##' @param len desired length of the independent sequences (to compute z values
##'   for contours)
##' @param interact logical; whether choose the starting values by cliking on
##'   the contour plot directly?
##' @param col.contour, ol.arrow colors for the contour lines and arrows
##'   respectively (default to be red and blue)
##' @return A list containing \item{par }{the solution for the local minimum}
##'   \item{value }{the value of the objective function corresponding to
##'   \code{par}} \item{iter}{the number of iterations; if it is equal to
##'   \code{control$nmax}, it's quite likely that the solution is not reliable
##'   because the maximum number of iterations has been reached}
##'   \item{gradient}{the gradient function of the objective function; it is
##'   returned by \code{\link[stats]{deriv}}} \item{persp}{a function to make
##'   the perspective plot of the objective function; can accept further
##'   arguments from \code{\link[graphics]{persp}} (see the examples below)}
##' @note Please make sure the function \code{FUN} provided is differentiable
##'   at \code{init}, what's more, it should also be 'differentiable' using
##'   \code{\link[stats]{deriv}} (see the help file)!
##' 
##' If the arrows cannot reach the local minimum, the maximum number of
##'   iterations \code{nmax} in \code{\link{ani.options}} may be increased.
##' @author Yihui Xie <\url{http://yihui.name}>
##' @seealso \code{\link[stats]{deriv}}, \code{\link[graphics]{persp}},
##'   \code{\link[graphics]{contour}}, \code{\link[stats]{optim}}
##' @references \url{http://en.wikipedia.org/wiki/Gradient_descent}
##' 
##' \url{http://animation.yihui.name/compstat:gradient_descent_algorithm}
##' @keywords optimize dynamic dplot
##' @examples
##' 
##' # default example 
##' oopt = ani.options(interval = 0.3, nmax = 50)
##' xx = grad.desc()
##' xx$par  # solution
##' xx$persp(col = "lightblue", phi = 30)   # perspective plot 
##' 
##' # define more complex functions; a little time-consuming 
##' f1 = function(x, y) x^2 + 3 * sin(y) 
##' xx = grad.desc(f1, pi * c(-2, -2, 2, 2), c(-2 * pi, 2)) 
##' xx$persp(col = "lightblue", theta = 30, phi = 30)
##' # or 
##' ani.options(interval = 0, nmax = 200)
##' f2 = function(x, y) sin(1/2 * x^2 - 1/4 * y^2 + 3) * 
##'     cos(2 * x + 1 - exp(y))  
##' xx = grad.desc(f2, c(-2, -2, 2, 2), c(-1, 0.5), 
##'     gamma = 0.1, tol = 1e-04)
##' 
##' \dontrun{ 
##' # click your mouse to select a start point 
##' xx = grad.desc(f2, c(-2, -2, 2, 2), interact = TRUE, 
##'     tol = 1e-04)
##' xx$persp(col = "lightblue", theta = 30, phi = 30)
##' 
##' # HTML animation pages 
##' ani.options(ani.height = 500, ani.width = 500, outdir = getwd(), interval = 0.3,
##'     nmax = 50, title = "Demonstration of the Gradient Descent Algorithm",
##'     description = "The arrows will take you to the optimum step by step.")
##' ani.start()
##' grad.desc()
##' ani.stop()
##' }
##' 
##' ani.options(oopt)
##' 
`grad.desc` <- function(FUN = function(x, y) x^2 + 2 * 
    y^2, rg = c(-3, -3, 3, 3), init = c(-3, 3), gamma = 0.05, 
    tol = 0.001, len = 50, interact = FALSE, col.contour = "red",
    col.arrow = "blue") {
    nmax = ani.options("nmax")
    interval = ani.options("interval")
    x = seq(rg[1], rg[3], length = len)
    y = seq(rg[2], rg[4], length = len)
    nms = names(formals(FUN)) 
    grad = deriv(as.expression(body(FUN)), nms, 
        function.arg = TRUE)
    z = outer(x, y, FUN)
    if (interact) {
        contour(x, y, z, col = "red", xlab = nms[1], ylab = nms[2], 
            main = "Choose initial values by clicking on the graph")
        xy = unlist(locator(1))
    }
    else {
        xy = init
    }
    newxy = xy - gamma * attr(grad(xy[1], xy[2]), "gradient")
    gap = abs(FUN(newxy[1], newxy[2]) - FUN(xy[1], xy[2]))
    i = 1
    while (gap > tol & i <= nmax) {
        contour(x, y, z, col = col.contour, xlab = nms[1], ylab = nms[2],
            main = eval(substitute(expression(z == x), list(x = body(FUN)))))
        xy = rbind(xy, newxy[i, ])
        newxy = rbind(newxy, xy[i + 1, ] - gamma * attr(grad(xy[i + 
            1, 1], xy[i + 1, 2]), "gradient"))
        arrows(xy[1:i, 1], xy[1:i, 2], newxy[1:i, 1], newxy[1:i, 
            2], length = par("din")[1] / 50, col = col.arrow)
        gap = abs(FUN(newxy[i + 1, 1], newxy[i + 1, 2]) - FUN(xy[i + 
            1, 1], xy[i + 1, 2]))
        Sys.sleep(interval)
        i = i + 1
    }
    ani.options(nmax = i -1)
    invisible(list(par = newxy[i - 1, ], value = FUN(newxy[i -
        1, 1], newxy[i - 1, 2]), iter = i - 1, gradient = grad, 
        persp = function(...) persp(x, y, z, ...)))
} 