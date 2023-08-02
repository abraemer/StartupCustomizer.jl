macro pkgtemplateconfig()
    return PKGTEMPLATECONFIG
end
function template(; kwargs...)
    @eval begin
        using PkgTemplates
        Template(;
            @pkgtemplateconfig()...,
	        $kwargs...)
    end
end
