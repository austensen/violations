
read_files <- function(indir, filename, col_spec, months = NULL) {
  pat <- stringr::str_c(filename, "\\d{8}\\.txt")
  
  files <- indir %>% 
    list.files(pattern = pat, full.names = TRUE) %>% 
    stringr::str_sort(decreasing = TRUE)
  
  if (is.null(months)) {
    months <- length(files)
  } 
  
  files %>% 
    magrittr::extract(1:months) %>%
    purrr::map(~ readr::read_lines(.x) %>% 
          stringr::str_replace_all("\"", "") %>% 
          stringr::str_c(collapse = "\n")) %>% 
    purrr::map_df(readr::read_delim, delim = "|", trim_ws = T, col_types = col_spec)
}