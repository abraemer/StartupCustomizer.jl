module StartupCustomizer

import InteractiveUtils
using Markdown
import Pkg

# don't export these? Better than exporting only some of them
# Pro: No name clashes
# Con: Need to type "StartupCustomizer..." but this is not done often so it's fine?
# export status, list, edit, add, remove

# Module interface
abstract type AbstractStartupModule end

"""
    short_description(::Type{<:AbstractStartupModule})
Return one sentence description of this module. Used by [`list`](!@ref).
"""
function short_description end

"""
    long_description(::Type{<:AbstractStartupModule})
Return complete description of this module. Used by [`describe`](!@ref).
"""
function long_description end
function _generate end
function _dependencies end
_dependencies(mod::AbstractStartupModule) = _dependencies(typeof(mod))

# Core functionality

include("parse.jl")

"""
    which()
Return the location of the default `startup.jl`.
"""
which() = joinpath(DEPOT_PATH[1], "config/startup.jl")
# matches more or less Base._local_julia_startup_file()

"""
    edit()
Open an editor of the `startup.jl` file.
"""
function edit(file=which())
    !ispath(dirname(file)) || mkpath(dirname(file))
    !isfile(file) || touch(file)
    InteractiveUtils.edit(file)
end

"""
    status()
List currently active modules in `startup.jl`.
"""
function status(; file = which())
    current_modules = _parse_startup_file(file)
    display(Markdown.MD(Markdown.List(_list.(current_modules))))
end

"""
    list()
List available modules.
"""
function list()
    modules = InteractiveUtils.subtypes(AbstractStartupModule)
    display(Markdown.MD(Markdown.List(_list.(modules))))
    return nothing
end

_list(mod::AbstractStartupModule) = Markdown.Paragraph("$mod")
_list(::CustomCode) = Markdown.Paragraph("CustomCode")

function _list(mod::Type{<:AbstractStartupModule})
    return Markdown.Paragraph("$mod: $(short_description(mod))")
end


"""
    describe(module)
Show detailed information about the module.
"""
function describe(mod::Type{<:AbstractStartupModule})
    display(long_description(mod))
    return nothing
end
describe(mod::AbstractStartupModule) = describe(typeof(mod))


"""
    add(modules...; file = which())
Add given `modules` to the `startup.jl`.
"""
function add(mods...; file = which())
    current_modules = _parse_startup_file(file)
    maybe_new_dependencies = String[]
    for mod in mods
        idx = findfirst(m -> typeof(m)==typeof(mod), current_modules)
        if !isnothing(idx)
            @info "Module $mod already enabled. Ignoring."
            continue
        end
        push!(current_modules, mod)
        append!(maybe_new_dependencies, _dependencies(mod))
    end
    _add_dependencies(maybe_new_dependencies)
    _regenerate_startup_file(file, current_modules)
end

function _add_dependencies(new_dependencies, startup_env=nothing)
    length(new_dependencies) == 0 && return
    infostr = Markdown.MD([md"The following dependencies might be added to the startup environment:",
            Markdown.List(Markdown.Paragraph.(new_dependencies))])
    @info infostr
    current_env = Base.active_project()
    isnothing(startup_env) ? Pkg.activate() : Pkg.activate(startup_env)
    Pkg.add(new_dependencies)
    Pkg.activate(current_env)
end

"""
    remove(modules...)
Remove given `modules` from the `startup.jl`.
"""
function remove(mods...; file = which())
    current_modules = _parse_startup_file(file)
    maybe_unneeded_dependencies = []
    for mod in mods
        idx = findfirst(x->typeof(x)==typeof(mod), current_modules)
        if isnothing(idx)
            @info "Module $mod not enabled. Ignoring."
            continue
        end
        deleteat!(current_modules, idx)
        append!(maybe_unneeded_dependencies, _dependencies(mod))
    end
    _regenerate_startup_file(file, current_modules)
    if length(maybe_unneeded_dependencies) > 0
        infostr = Markdown.MD([md"The following dependencies in the startup environments might be not needed anymore:",
            Markdown.List(Markdown.Paragraph.(maybe_unneeded_dependencies))])
        @info infostr
    end
end

# Include modules

include("modules/revise.jl")
include("modules/ohmyrepl.jl")
include("modules/pkgtemplates.jl")
include("modules/numberedprompt.jl")

end # module
