library(magrittr)


prep_vars <- function(.x) {
  dplyr::if_else(is.na(.x), "", stringr::str_trim(as.character(.x), "both"))
}

make_xml <- function(.data) {
  glue::glue_data(.data,
                  '<Address ID="{.id}">\\
                  <FirmName />\\
                  <Address1>{unit}</Address1>\\
                  <Address2>{street}</Address2>\\
                  <City>{city}</City>\\
                  <State>{state}</State>\\
                  <Zip5>{zip}</Zip5>\\
                  <Zip4></Zip4>\\
                  </Address>
                  ')
}

wrap_xml <- function(.addresses, .username) {
  glue::glue('http://production.shippingapis.com/ShippingAPI.dll?API=Verify&XML=\\
              <AddressValidateRequest USERID="{.username}">\\
              <IncludeOptionalElements>false</IncludeOptionalElements>\\
              <ReturnCarrierRoute>false</ReturnCarrierRoute>\\
              {glue::collapse(.addresses)}\\
              </AddressValidateRequest>
              ')
}
 
get_adds <- function(.request) {
  .request %>% 
    XML::xmlParse() %>% 
    XML::xmlToDataFrame() %>% 
    dplyr::select(.unit = Address1,
                  .street = Address2,
                  .city = City,
                  .state = State,
                  .zip = Zip5)
}


get_usps <- function(.df, .unit, .street, .city, .state, .zip, .username) {
  
  # USPS API can only take 5 addresses at a time
  n_groups <- (nrow(.df) %/% 5) + 1
  
  input_names <- c(deparse(substitute(.unit)),
                   deparse(substitute(.street)),
                   deparse(substitute(.city)),
                   deparse(substitute(.state)),
                   deparse(substitute(.zip)))
  
  # standardize names for use in later function calls building API request
  slim_df <- select_(.df, .dots = input_names)
  slim_df_named <- purrr::set_names(slim_df, c("unit", "street", "city", "state", "zip"))
  
  # change all address parts to character and NA -> "" for building XML for request
  clean_adds_df <- dplyr::mutate_all(slim_df_named, prep_vars)
  
  # into groups of 5, and all address parts into nested dataframe for map functions
  nested_df <- clean_adds_df %>% 
    dplyr::mutate(.temp_id = 1:nrow(.),
                  .group = dplyr::ntile(.temp_id, n_groups))  %>%
    dplyr::group_by(.group) %>%
    dplyr::mutate(.id = dplyr::row_number(.temp_id)) %>%
    tidyr::nest(.key = .raw_adds)
  
  # build XML of raw address info for 5 addresses at a time
  xml_adds_df <- dplyr::mutate(nested_df, .xml_adds = purrr::map(.raw_adds, make_xml))
  
  # wrap the XML addresses with url and other XML for API request
  api_rec_df <- dplyr::mutate(xml_adds_df, .req = purrr::map_chr(.xml_adds, wrap_xml, .username = .username))
  
  # send out api request and parse XML response into dataframe
  new_adds_df <- dplyr::mutate(api_rec_df, .new_adds = purrr::map(.req, get_adds))
  
  # unnest the clean addresses grouped, drop temp variables, and add cleaned address back to input data
  unnested_df <- tidyr::unnest(new_adds_df)
  new_adds_only_df <- dplyr::select(unnested_df, .unit, .street, .city, .state, .zip)
  bind_cols(.df, new_adds_only_df)
}



  
