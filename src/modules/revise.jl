struct Revise <: AbstractStartupModule end

short_description(::Type{Revise}) = "Enable Revise.jl on startup"

long_description(::Type{Revise}) = md"""
`Revise.jl` reevaluates julia files when the code is changed and thus enables a dynamic workflow.

If you don't know what `Revise.jl` is you should visit [Workflow tips](https://docs.julialang.org/en/v1/manual/workflow-tips/#Revise-based-workflows) for more information.
"""

_generate(::Revise) = read("templates/revise.jl", String)
_dependencies(::Type{Revise}) = ["Revise"]
