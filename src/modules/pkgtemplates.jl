struct PkgTemplates <: AbstractStartupModule
    config::String
end

PkgTemplates(; kwargs...) = join(("$k = $v" for (k,v) in kwargs), ",\n\t\t\t")

short_description(::Type{PkgTemplates}) = "Define a function `template(; kwargs)` that generates a PkgTemplates.Template"

long_description(::Type{PkgTemplates}) = md"""
    PkgTemplates(config)

PkgTemplates.jl offers `Template`s for generating the boilerplate for a good Julia package.
This module puts a function called `template` into the `startup.jl` that return a Template with
fixed configuration.

See [PkgTemplates user guide](https://juliaci.github.io/PkgTemplates.jl/stable/user/#Saving-Templates-1) for more information.

## Examples:
- `PkgTemplates("julia=VERSION, plugins=[PkgTemplates.Git(branch=\\"main\\", ssh=true)]")`
- `PkgTemplates(; julia="VERSION", plugins="[PkgTemplates.Git(branch=\\"main\\", ssh=true)]")`
- `PkgTemplates(; julia=VERSION, plugins=[PkgTemplates.Git(branch="main", ssh=true),])`

**Note**: The last call is conceptually different from the two above! The parameters are *evaluated*
before they are passed, so the resulting configuration requires `PkgTemplates.jl` to be loaded and the string actually looks like:
`"julia = 1.9.2, plugins = [PkgTemplates.Git(String[], nothing, nothing, \"main\", true, true, false, false)]"`
"""

_generate(pkgt::PkgTemplates) = """
function template(; kwargs...)
    @eval begin
        using PkgTemplates
        Template(;
	        $(_format(pkgt)))
    end
end
"""

_dependencies(::Type{PkgTemplates}) = ["PkgTemplates"]

function _format(pkgt::PkgTemplates)
    isempty(pkgt.config) && return "kwargs..."
    endswith(pkgt.config, ",") && return pkgt.config*"\n\t\t\tkwargs..."
    return pkgt.config*",\n\t\t\tkwargs..."
end
