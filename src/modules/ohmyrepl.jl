struct OhMyREPL <: AbstractStartupModule end

short_description(::Type{OhMyREPL}) = "Enable OhMyREPL.jl on startup making the REPL look nice!"

long_description(::Type{OhMyREPL}) = md"""
    OhMyREPL()

Enable OhMyRepl.jl on startup, which makes everything in the REPL look nicer.

See [Documentation](https://kristofferc.github.io/OhMyREPL.jl/latest/) for more information.
"""

_generate(::OhMyREPL) = read("templates/ohmyrepl.jl", String)
_dependencies(::Type{OhMyREPL}) = ["OhMyREPL"]
