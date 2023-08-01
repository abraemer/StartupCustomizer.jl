# StartupCustomizer.jl
*Easy customization of startup.jl*

The goal of this package is to provide a simple and uniform way for other packages (like e.g. `Revise.jl`) to be installed into Julia's `startup.jl` file. Instead of having to locate, open and edit the file, with this package users could do something akin to:
```julia
julia> import StartupCustomizer
julia> StartupCustomizer.add(StartupCustomizer.Revise())
```
This would then install `Revise.jl` into the global environment and paste the initialization code into `startup.jl` without the user needing to know anything else.

## User Guide
You can use `status()` to see what currently is in your startup.jl, `list()` to get a list of available modules, `describe(module)` to get detailed information on a module, `add(module...)`/`remove(module...)` to add/remove modules and `edit()` to edit the startup.jl directly by hand. Notably `add`ing modules also installs required packages into the global default environment.


## Developer Guide
The main concept of this package is that of a `StartupModule` which handles something you want to put into your startup.jl. All one needs to do to add something new is to make a subtype of `AbstractStartupModule` and implement 4 methods `short_description`, `long_description`, `_dependencies` and `_generate`.

For `add`,`remove`,`status`, this package scans `startup.jl` to determine what it has written there previously. Only parts that are recognized are ever altered. This package marks section by wrapping them in comments like `# begin StartupCustomizer.Revise()` and `# end StartupCustomizer.Revise()`. These comments also serve as storage for the parameters of the modules, so modules should take care that they are reconstructable from their string representation.