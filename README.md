# StartupCustomizer.jl
*Easy customization of startup.jl*

The goal of this package is to provide a simple and uniform way for other packages (like e.g. `Revise.jl`) to be installed into Julia's `startup.jl` file. Instead of having to locate, open and edit the file, with this package users could do something akin to:
```julia
julia> import StartupCustomizer
julia> StartupCustomizer.add(StartupCustomizer.Revise())
```
This would then install `Revise.jl` into the global environment and paste the initialization code into `startup.jl` without the user needing to know anything else.

## Quick start
Once this is registered you can simply enter into your REPL:
```julia
julia> Pkg.add("StartupCustomizer")
# some output
julia> import StartupCustomizer
julia> StartupCustomizer.add(StartupCustomizer.Revise(), StartupCustomizer.OhMyREPL())
# Revise.jl and OhMyREPL.jl are now added to your startup.jl
```
Having `Revise.jl` and `OhMyREPL.jl` is probably a sensible default for most users.
## User Guide
You can use:
- `StartupCustomizer.which()` to see where your startup file is,
- `StartupCustomizer.status()` to see what currently is in your startup.jl
- `StartupCustomizer.list()` to get a list of available modules
- `StartupCustomizer.describe(module)` to get detailed information on a module
- `StartupCustomizer.add(module...)`/`StartupCustomizer.remove(module...)` to add/remove modules 
- `StartupCustomizer.edit()` to edit the startup.jl directly by hand. 

Notably `add`ing modules also installs required packages into the global default environment. 

You can safely remove `StartupCustomizer.jl` after you modified your `startup.jl` with `Pkg.remove("StartupCustomizer")`.

Currently available modules are:
 - `Revise`: loads [Revise.jl](https://docs.julialang.org/en/v1/manual/workflow-tips/#Revise-based-workflows)
 - `OhMyREPL`: enables [OhMyRepl.jl](https://kristofferc.github.io/OhMyREPL.jl/latest/)
 - `NumberedPrompt`: Switches REPL to a IPython like numbered prompt style. See [manual](https://docs.julialang.org/en/v1/stdlib/REPL/#Numbered-prompt).
 - `PkgTemplates`: defines a function `template(; kwargs...)` which can be customized for personal preference (see their [documentation](https://juliaci.github.io/PkgTemplates.jl/stable/user/#Saving-Templates-1))

## Developer Guide
The main concept of this package is that of a `StartupModule` which handles something you want to put into your startup.jl. All one needs to do to add something new is to make a subtype of `AbstractStartupModule` and implement 4 methods `short_description`, `long_description`, `_dependencies` and `_generate`. It is recommended to put the code a module emit into the `/templates` directory to keep things tidy and have editor support for writing that code.

For `add`,`remove`,`status`, this package scans `startup.jl` to determine what it has written there previously. Only parts that are recognized are ever altered. This package marks section by wrapping them in comments like `# begin StartupCustomizer.Revise()` and `# end StartupCustomizer.Revise()`. These comments also serve as storage for the parameters of the modules, so modules should take care that they are reconstructable from their string representation.