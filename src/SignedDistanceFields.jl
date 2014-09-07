module SignedDistanceFields

using Images, Color, FixedPointNumbers

function sweeprow!(img, y, out, itr)
	dist = -1
	for x in itr
		val = img[y, x]
		dist < 0 && !val && continue
		dist = val ? 0 : dist + 1
		out[y, x] = min(out[y, x], dist^2)
	end
end

function sqdistancetransform(img)
	# Calculate an upper bound for the
	# squared distance between two pixels
	bound = prod(size(img))^2

	# Calculate the one-dimensional distance
	# transform for each row
	sqdist_x = fill(bound, size(img))
	for y in 1:size(img, 1)
		sweeprow!(img, y, sqdist_x, 1:size(img, 2))
		sweeprow!(img, y, sqdist_x, reverse(1:size(img, 2)))
	end

	sqdist = fill(bound, size(img))
	for x in 1:size(img, 2)
		for y in 1:size(img, 1)
			for yp in 1:size(img, 1)
				sqdist_y = (y - yp)^2
				sqdist_y > sqdist[y, x] && break
				sqdist[y, x] = min(sqdist[y, x], sqdist_x[yp, x] + sqdist_y)
			end
		end
	end

	sqdist
end

# TODO: Determine which orientation (rc, cr) is better for cache locality

img = [
	false false false;
	true false false;
	false false false;
]
println(sqdistancetransform(img))

path = "/Users/yurivish/Desktop/a_1000.jpg"
# path = "/Users/yurivish/Desktop/a_500.jpg"

img = convert(Array, imread(path))

println("img[1] = ", img[1])
# bitmap = map(c -> !(c.c.r == 1 && c.c.g == 1 && c.c.b == 1), img)
bitmap = map(c -> c != 1, img)

# TODO: Can we calculate the SDF in one pass rather than two?
sdf(img) = sqrt(sqdistancetransform(img)) - sqrt(sqdistancetransform(!img))

# println(bitmap)
println("sdfing.")
@time result = sdf(bitmap)
println("done sdfing.")

# Rescale to [0, 1]
result = abs(result)
result -= minimum(result)
result /= maximum(result)

imwrite(map(b -> RGB(b, b, b), result), "out.png")

end # module
