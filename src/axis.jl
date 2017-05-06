immutable Axis <: TikzElement
    plots::Vector{Plot}
    options::Vector{String}
end

Base.push!(axis::Axis, plot::Plot) = push!(axis.plots, plot)

function Axis(plot::Vector{Plot}, args::Vararg{Pair})
    Axis(plot, create_options(args))
end

function Axis(args::Vararg{Pair})
    Axis(Plot[], args...)
end

function print_tex(io_main::IO, axis::Axis)
    print_indent(io_main) do io
        print(io, "\\begin{axis}")
        print_options(io, axis.options)
        for plot in axis.plots
            print_tex(io, plot)
        end
        print(io, "\\end{axis}")
    end
end
