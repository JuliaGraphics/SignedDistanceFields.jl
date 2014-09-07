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

function sqdist1d(vec::Vector{Bool})
	# Sweep forward; then sweep back.
	# TODO: Investigate immediate sweepback
	# as far back as required; better cache
	# locality that way.
	distsq = fill(typemax(Int) >> 2, size(vec)) # Choose the largest value s.t. it squared + c < typemax

	d = -1
	for i in 1:length(vec)
		val = vec[i]
		d < 0 && !val && continue
		d = val ? 0 : d + 1
		distsq[i] = d^2
	end

	d = -1
	for i in length(vec):-1:1
		val = vec[i]
		d < 0 && !val && continue
		d = val ? 0 : d + 1
		distsq[i] = min(distsq[i], d^2)
	end

	distsq
end

function sqdist2d(arr)
	dists2 = fill(typemax(Int), size(arr))

	dists = mapslices(sqdist1d, arr, 1)
	println("Column distances:")
	println(dists)
	
    for i = 1:size(dists,1)
		for j = 1:size(dists,2)
			for k = 1:size(dists,2)
		        dists2[i, j] = min(dists[i, j], dists[i, k] + (j - k)^2)
			end
		end
    end

	println("Sqdist2d:")
    dists2
end

# row = [false, false, false, false, false, false, false, false, true, true, false, true];
# sqdist1d(row)
mat = [
	true false false;
	false false false;
	false false true
];

println("Matrix:")
mat
sqdist2d(mat)


# TODO: Determine which orientation (rc, cr) is better for cache locality



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
