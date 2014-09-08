module SignedDistanceFields

# Given a 2D image, this package calculates its signed distance field
# via the Euclidean distance transform, with an approach due to
# Saito and Toriwaki (1994).
#
# A recent comparative survey of EDT algorithms found Saito's
# algorithm to be the simplest among all while still remaining 
# one of the fastest approaches.

# Link to survey:
# http://www.agencia.fapesp.br/arquivos/survey-final-fabbri-ACMCSurvFeb2008.pdf

export edf, sdf

function xsweep!(img, out, y, xitr)
	dist = -1
	for x in xitr
		val = img[y, x]
		dist < 0 && !val && continue
		dist = val ? 0 : dist + 1
		out[y, x] = min(out[y, x], dist^2)
	end
end

function edf_sq(img)
	# An upper bound for the distance between two pixels
	maxval = prod(size(img))^2

	# Calculate the row-wise distance transform for each row
	# in two passes, taking the minimum of the distance-from-
	# left and distance-from-right.
	rowdf_sq = fill(maxval, size(img))
	for y in 1:size(img, 1)
		xsweep!(img, rowdf_sq, y, 1:size(img, 2))
		xsweep!(img, rowdf_sq, y, reverse(1:size(img, 2)))
	end

	# Use the row-wise information to compute the full distance transform
	df_sq = fill(maxval, size(img))
	for x in 1:size(img, 2)
		for y in 1:size(img, 1)
			for yp in 1:size(img, 1)
				ydistsq = (y - yp)^2
				ydistsq > df_sq[y, x] && break
				df_sq[y, x] = min(df_sq[y, x], rowdf_sq[yp, x] + ydistsq)
			end
		end
	end

	df_sq
end

edf(img) = sqrt(edf_sq(img))
sdf(img) = sqrt(edf_sq(img)) - sqrt(edf_sq(!img))

end # module
