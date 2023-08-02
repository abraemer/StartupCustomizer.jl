struct NumberedPrompt <: AbstractStartupModule end

short_description(::Type{NumberedPrompt}) = "Enable IPython like numbered prompts."

long_description(::Type{NumberedPrompt}) = md"""
    NumberedPrompt()

Switches the REPL to a numbered prompt mode akin to the IPython REPL. All results are saved and
can be referred to by the prompt's number.

See [Manual](https://docs.julialang.org/en/v1/stdlib/REPL/#Numbered-prompt) for more information.
"""

_generate(::NumberedPrompt) = read("templates/numberedprompt.jl", String)
_dependencies(::Type{NumberedPrompt}) = []
