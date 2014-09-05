module SignedDistanceFields

using LowDimNearestNeighbors, Images

export sdf

# Define multidimensional vector types for testing
immutable Vec2{T <: Unsigned}
	x::T
	y::T
end
Vec2(x, y) = Vec2(convert(Unsigned, x), convert(Unsigned, y))
Base.getindex(v::Vec2, n::Int) = n == 1 ? v.x : n == 2 ? v.y : throw("Vec2 indexing error.")
Base.length(v::Vec2) = 2
Base.rand{T}(::Type{Vec2{T}}) = Vec2(rand(T), rand(T))

# function sdf()

# end


path = "/Users/yurivish/Desktop/a.png"
I = 1273
J = 1250

path = "/Users/yurivish/Desktop/a_small.png"
I = 102
J = 100

# path = "/Users/yurivish/Desktop/a_smaller.png"
# I = 306
# J = 300

img = convert(Array, imread(path))



chan = img[:, :, 1] .< 0xff

count(f-> f, chan)
count(f-> !f, chan)

filled = Vec2[]



for i=1:I,j=1:J
	chan[i,j] && push!(filled, Vec2(i, j))
end

println(length(filled))

preprocess!(filled)

function fn(i, j)
	i == 1 && println("fn($i, $j)")
	a = Vec2(i, j)
	b = nearest(filled, a)
	sqrt((a[1] - b[1])^2 + (a[2] - b[2])^2)
end

@time result = [fn(i, j)::Float64 for i=1:I, j=1:J]

# result = clamp(result, 0x00, 10)
# result -= minimum(result)
# result /= maximum(result)

println(result[1:10])
println(summary(result))

imwrite(result, "out.png")

# println(sort(vec(result)))

end # module
