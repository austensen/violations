download_files <- function(url, filename, outdir) {
  pat <- str_c(filename, "*\\d{8}")
  
  file <- str_extract(url, pat)
  
  dir.create(outdir, showWarnings = FALSE)
  
  download.file(url, str_c(outdir, "/", file, ".zip"), mode = "wb", quiet = TRUE)
  
  unzip(str_c(outdir, "/", file, ".zip"), exdir = outdir)
}
