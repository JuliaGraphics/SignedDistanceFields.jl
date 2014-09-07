module SignedDistanceFields

using LowDimNearestNeighbors
using Images, Color, FixedPointNumbers

# Define multidimensional vector types for testing
immutable Vec2{T <: Unsigned}
	x::T
	y::T
end
Vec2(x, y) = Vec2(convert(Unsigned, x), convert(Unsigned, y))
Base.getindex(v::Vec2, n::Int) = n == 1 ? v.x : n == 2 ? v.y : throw("Vec2 indexing error.")
Base.length(v::Vec2) = 2
Base.rand{T}(::Type{Vec2{T}}) = Vec2(rand(T), rand(T))


path = "/Users/yurivish/Desktop/a.png"
I = 1273
J = 1250

path = "/Users/yurivish/Desktop/a_medium.png"
I = 509
J = 500

path = "/Users/yurivish/Desktop/a_smaller.png"
I = 306
J = 300

path = "/Users/yurivish/Desktop/a_small.png"
I = 102
J = 100

firsttrue(vec) = for i in 1:length(vec)    vec[i] && return i end
lasttrue(vec)  = for i in length(vec):-1:1 vec[i] && return i end

function dt1d(vec::Vector{Bool})
	distsq = fill(typemax(Int), size(vec))

	d = 0
	for i in firsttrue(vec):length(vec)
		val = vec[i]
		d = val ? 0 : d + 1
		distsq[i] = d^2
	end

	d = 0
	for i in lasttrue(vec):-1:1
		val = vec[i]
		d = val ? 0 : d + 1
		distsq[i] = min(distsq[i], d^2)
	end

	distsq
end

dt1d([false, false, true, false, false, false, false, false, true, true, false, true])




img = convert(Array, imread(path))

chan = img[:, :, 1] .< 0xff

count(f-> f, chan)
count(f-> !f, chan)

filled = Vec2{Uint8}[]

for i=1:I,j=1:J
	chan[i,j] && push!(filled, Vec2{Uint8}(i, j))
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

# result = clamp(result, 0, 20)
# result /= maximum(result)

println(result[1:10])
println(summary(result))

# imwrite(float(chan), "out.png")
imwrite(result, "out.png")

# println(sort(vec(result)))

end # module
