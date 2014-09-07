module SignedDistanceFields

using Images, Color, FixedPointNumbers

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
				rowdist = (j - k)^2
				rowdist > all[i, j] && break
		        all[i, j] = min(all[i, j], distsq[i, k] + rowdist)
			end
		end
    end

    all
end

# TODO: Determine which orientation (rc, cr) is better for cache locality

path = "/Users/yurivish/Desktop/a_1000.jpg"
# path = "/Users/yurivish/Desktop/a_500.jpg"

img = convert(Array, imread(path))

println("img[1] = ", img[1])
# bitmap = map(c -> !(c.c.r == 1 && c.c.g == 1 && c.c.b == 1), img)
bitmap = map(c -> c != 1, img)

# TODO: Can we calculate the SDF in one pass rather than two?
# TODO: + -> -
sdf(img) = sqrt(sqdistancetransform(img)) - sqrt(sqdistancetransform(!img))

# println(bitmap)
@time result = sdf(bitmap)

# Rescale to [0, 1]
result = abs(result)
result -= minimum(result)
result /= maximum(result)

imwrite(map(b -> RGB(b, b, b), result), "out.png")

end # module
