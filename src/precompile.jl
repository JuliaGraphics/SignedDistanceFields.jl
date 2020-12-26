function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    @assert precompile(Tuple{typeof(sdf),Matrix{Bool}})   # time: 0.17639625
    @assert precompile(Tuple{typeof(edf_sq),Matrix{Bool}})   # in case the above doesn't work
    @assert precompile(Tuple{typeof(downsample),Matrix{Float64},Int})   # time: 0.0495947
end
