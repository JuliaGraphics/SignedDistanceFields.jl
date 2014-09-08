module SignedDistanceFields

# Given a 2D image, calculate its Euclidean distance transform
# with an approach due to Saito and Toriwaki (1994).
#
# Here's a link to a comparative survey of EDT algorithms, which 
# found Saito's algorithm to be the simplest, and almost as fast
# as Meijster and Maurer's approaches.
# http://www.agencia.fapesp.br/arquivos/survey-final-fabbri-ACMCSurvFeb2008.pdf


using Images, Color, FixedPointNumbers

export edf, sdf

function xsweep!(img, out, y, xitr)
	dist = -1
	for x in xitr
		val = img[y, x]
		dist < 0 && !val && continue
		dist = val ? 0 : dist + 1
		rowdf_sq[y, x] = min(rowdf_sq[y, x], dist^2)
	end
end

function edf_sq(img)
	# An upper bound for the distance between two pixels
	maxval = prod(size(img))^2

	# Calculate the row-wise distance transform for each row
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
