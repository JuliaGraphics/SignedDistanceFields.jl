module SignedDistanceFields

using Images, Color, FixedPointNumbers

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
	cdists = mapslices(sqdist1d, arr, 1)
	rdists = fill(typemax(Int) >> 2, size(arr))

	println("Column distances:")
	println(cdists)
	
    for i = 1:size(cdists, 1)
		for j = 1:size(cdists, 2)
			for k = 1:size(cdists, 2)
		        rdists[i, j] = min(rdists[i, j], cdists[i, k] + (j - k)^2)
			end
		end
    end

	println("Sqdist2d:")
    rdists
end

function sqdistancetransform(img)
	maxval = typemax(Int) >> 2
	distsq = fill(maxval, size(img))

	for r = 1:size(img, 2)
		 d = -1
		 for c in 1:size(img, 1)
		 	val = img[c, r]
		 	d < 0 && !val && continue
		 	d = val ? 0 : d + 1
		 	distsq[c, r] = d^2
		 end

		 d = -1
		 for c in size(img, 1):-1:1
		 	val = img[c, r]
		 	d < 0 && !val && continue
		 	d = val ? 0 : d + 1
		 	distsq[c, r] = min(distsq[c, r], d^2)
		 end
	end

	all = fill(maxval, size(img))

    for i = 1:size(distsq, 1)
		for j = 1:size(distsq, 2)
			for k = 1:size(distsq, 2)
		        all[i, j] = min(all[i, j], distsq[i, k] + (j - k)^2)
			end
		end
    end

    all
end

# row = [false, false, false, false, false, false, false, false, true, true, false, true];
# sqdist1d(row)
mat = [
	false false false;
	true true false;
];

println("Matrix:")
mat
sqdistancetransform(mat)


# TODO: Determine which orientation (rc, cr) is better for cache locality


path = "/Users/yurivish/Desktop/a.png"
# path = "/Users/yurivish/Desktop/a_medium.png"
# path = "/Users/yurivish/Desktop/a_smaller.png"
# path = "/Users/yurivish/Desktop/a_small.png"


img = convert(Array, imread(path))
# println(img)
bitmap = map(c -> c.c.r == 1 && c.c.g == 1 && c.c.b == 1, img)

# imwrite(map(b -> RGB(b, b, b), bitmap), "out_b.png")

distancetransform(img) = sqrt(sqdistancetransform(img))# - sqdistancetransform(!img))

# println(bitmap)
@time result = distancetransform(bitmap)
# println(result)
# result = sqrt(result) # type-unstable
result /= maximum(result)

# println(result[1:10])
# println(result)
# println(summary(result))

imwrite(map(b -> RGB(b, b, b), result), "out.png")

end # module
