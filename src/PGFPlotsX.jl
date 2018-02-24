__precompile__()

module PGFPlotsX

import MacroTools: prewalk, @capture

using ArgCheck
using Compat
using Compat.Unicode            # for lowercase
using DataStructures
using DocStringExtensions
using Parameters
using Requires

export TikzDocument, TikzPicture
export Axis, GroupPlot, PolarAxis
export Plot, PlotInc, Plot3, Plot3Inc, Expression, EmptyLine, Coordinates,
    TableData, Table, Graphics, Legend, LegendEntry
export @pgf, pgfsave, print_tex, latexengine, latexengine!, CUSTOM_PREAMBLE,
    push_preamble!

const DEBUG = haskey(ENV, "PGFPLOTSX_DEBUG")
const CUSTOM_PREAMBLE_PATH = joinpath(@__DIR__, "..", "deps", "custom_preamble.tex")
const AbstractDict = Union{Dict, OrderedDict}

if !isfile(joinpath(@__DIR__, "..", "deps", "deps.jl"))
    error("""please run Pkg.build("PGFPlotsX") before loading the package""")
end
include("../deps/deps.jl")

print_tex(io::IO, a, b) = print_tex(io, a)
print_tex(a) = print_tex(STDOUT, a)

include("options.jl")
include("utilities.jl")

print_tex(io::IO, str::AbstractString) = print(io, str)

"""
    $SIGNATURES

Real numbers are printed as is, except for non-finite representation.
"""
function print_tex(io::IO, x::Real)
    if isfinite(x)
        print(io, x)
    elseif isnan(x)
        print(io, "nan")
    elseif isinf(x)
        s = x > 0 ? "+" : "-"
        print(io, "$(s)inf")
    else
        throw(ArgumentError("Don't know how to print $x for LaTeX."))
    end
end

"""
    $SIGNATURES

Print vectors as comma-delimited lists between `{}`s. Useful for eg
`/pgfplots/xtick`.
"""
function print_tex(io::IO, vs::AbstractVector)
    print(io, "{")
    for (i, elt) in enumerate(vs)
        i == 1 || print(io, ", ")
        print_tex(io, elt)
    end
    print(io, "}")
end

print_tex(io::IO,   v) = throw(ArgumentError(string("No tex function available for data of type $(typeof(v)). ",
                                                  "Define one by overloading print_tex(io::IO, data::T) ",
                                                  "where T is the type of the data to dispatch on.")))


"""
An `AxisElement` is a component of an `Axis`. It can be a `Plot` or a `RawString` etc.
"""
abstract type AxisElement <: OptionType end

include("axiselements.jl")

"""
A `TikzElement` is a component of a `TikzPicture`. It can be a node or an `Axis` etc.
"""
abstract type TikzElement <: OptionType end

include("axislike.jl")
include("tikzpicture.jl")
include("tikzdocument.jl")
include("requires.jl")
include("build.jl")

if DEFAULT_ENGINE == "PDFLATEX"
    latexengine!(PDFLATEX)
end

end # module
