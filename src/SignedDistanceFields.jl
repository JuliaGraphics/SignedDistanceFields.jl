module SignedDistanceFields

# This package calculates the signed distance field for 2d images
# using an approach due to Saito and Toriwaki (1994). The
# generalization to 3d is straightforward but not implemented.
#
# A recent comparative survey of algorithms for the Euclidean distance
# transform (upon which the SDF is based) found Saito's algorithm to be
# a good tradeoff between simplicity and performance. Those interested
# in the fastest approach should look at Meijster's algorithm, which 
# is an optimization of the basic approach implemented below.
#
# Link to survey:
# http://www.agencia.fapesp.br/arquivos/survey-final-fabbri-ACMCSurvFeb2008.pdf

export edf, sdf

# function xsweep!(img, out, y, xitr)
# 	dist = -1
# 	for x in xitr
# 		val = img[y, x]
# 		dist < 0 && !val && continue
# 		dist = val ? 0 : dist + 1
# 		out[y, x] = min(out[y, x], dist^2)
# 	end
# end

function xsweep!(row, out)
	dist = -1
	for (i, val) in enumerate(row)
		dist < 0 && !val && continue
		dist = val ? 0 : dist + 1
		out[i] = min(out[i], dist^2)
	end

	# for x in xitr
	# 	val = img[y, x]
	# 	dist < 0 && !val && continue
	# 	dist = val ? 0 : dist + 1
	# 	out[y, x] = min(out[y, x], dist^2)
	# end
end

function edf_sq(img)
	@assert ndims(img) == 2 "Image must be two-dimensional"

	# An upper bound for the distance between two pixels
	maxval = prod(size(img))^2
	ncols, nrows = size(img)

	# Calculate the row-wise distance transform for each row
	# in two passes, taking the minimum of the distance-from-
	# left and distance-from-right.
	rowdf_sq = fill(maxval, size(img))
	for y in 1:ncols
		# xsweep!(img, rowdf_sq, y, 1:nrows)
		# xsweep!(img, rowdf_sq, y, reverse(1:nrows))
		xsweep!(sub(img, y, 1:nrows), sub(rowdf_sq, y, 1:nrows))
		xsweep!(sub(img, y, reverse(1:nrows)), sub(rowdf_sq, y, reverse(1:nrows)))
	end

	# Use the row-wise information to compute the full distance transform
	df_sq = fill(maxval, size(img))
	for x in 1:nrows
		for y in 1:ncols
			for yp in 1:ncols
				ydistsq = (y - yp)^2
				ydistsq > df_sq[y, x] && break
				df_sq[y, x] = min(df_sq[y, x], rowdf_sq[yp, x] + ydistsq)
			end
		end
	end

	df_sq
end

edf(img) = sqrt(edf_sq(img))
edf(img, xsize, ysize=xsize) = downsample(edf(img), xsize, ysize)

sdf(img) = sqrt(edf_sq(img)) - sqrt(edf_sq(!img))
sdf(img, xsize, ysize=xsize) = downsample(sdf(img), xsize, ysize)

function downsample(img, xsize, ysize=xsize)
	yscale = div(size(img, 1), ysize)
	xscale = div(size(img, 2), xsize)

	# Make sure we're downsampling by integer amounts
	@assert yscale == size(img, 1) / ysize &&
			xscale == size(img, 2) / xsize

	out = Array(Float64, xsize, ysize)

	for y in 1:ysize
		for x in 1:xsize
			yinds = (1 + (y-1) * yscale):(y * yscale)
			xinds = (1 + (x-1) * xscale):(x * xscale)
			out[y, x] = mean(sub(img, yinds, xinds))
		end
	end

	out
end

end # module
