#' Write vector to an existing GRASS session
#'
#' Write a raster to an existing GRASS session with handling for very big rasters.
#' @param vect Raster layer.
#' @param vname Name of vector in GRASS.
#' @param tempDir Temporary directory.
#' @return Nothing (exports a vector to a GRASS session so it can be used by other functions).
#' @export
exportVectToGrass <- function(
	vect,
	vname = 'vect',
	tempDir = raster::tmpDir()
) {

	tryWrite <- function(vect, vname) {
		
		# ensure spatial data frame to avert error
		vectClass <- class(vect)
		if (vectClass == 'SpatialPoints') vect <- methods::as(vect, 'SpatialPointsDataFrame')
		if (vectClass %in% c('SpatialLines', 'SpatialLinesDataFrame')) vect <- methods::as(vect, 'SpatialPolygonsDataFrame')
		if (vectClass == 'SpatialPolygons') vect <- methods::as(vect, 'SpatialPolygonsDataFrame')

		rgrass7::writeVECT(vect, vname='vect', v.in.ogr_flags=c('quiet', 'overwrite'))
	
	}

	# fast export
	success <- tryCatch(tryWrite(vect), error=function(err) return(FALSE))
	
	# slow but error-resistant export
	if (class(success) == 'logical' && !success) {

		raster::shapefile(vect, paste0(tempDir, '/', vname), overwrite=TRUE)
		rgrass7::execGRASS('v.import', input=paste0(tempDir, '/', vname, '.shp'), output=vname, flags=c('overwrite', 'quiet'))
		
	}

}