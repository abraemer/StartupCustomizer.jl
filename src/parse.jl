struct CustomCode
    content::String
end

_generate(cc::CustomCode) = cc.content
_dependencies(::CustomCode) = String[]

function _parse_startup_file(file)
    lines = rstrip.(readlines(file))
    module_starts = findall(_match_module_start, lines)
    module_ends = findall(_match_module_end, lines)

    content = []
    atline = 1
    atmodule = 1
    push!(module_starts, length(lines)+1) # this hack makes for cleaner conditionals in the loop
    while atline <= length(lines)
        if module_starts[atmodule] == atline
            # we are in the beginning line of module
            # so parse that and skip to end
            push!(content, _parse_module(lines[atline]))
            atline = module_ends[atmodule]+1
            atmodule += 1
        else
            # this is custom code
            push!(content, CustomCode(join(lines[atline:module_starts[atmodule]-1], "\n")))
            atline = module_starts[atmodule]
        end
    end
    return content
end

function _match_module_start(line)
    !isnothing(match(r"^# begin StartupCustomizer.\w+\(.*\)$", line))
end

function _match_module_end(line)
    !isnothing(match(r"^# end StartupCustomizer.\w+\(.*\)$", line))
end

function _parse_module(line)
    moddef = match(r"^# begin (StartupCustomizer.\w+\(.*\))$", line)[1]
    return eval(Meta.parse(moddef))
end

function _regenerate_startup_file(file, modules)
    open(file, "w") do f
        for mod in modules
            generate(f, mod)
        end
    end
end

function generate(io, cc::CustomCode)
    write(io, cc.content, "\n")
end

function generate(io, mod::AbstractStartupModule)
    write(io, "# begin $(mod)\n")
    write(io, _generate(mod))
    write(io, "# end $(mod)\n")
end
