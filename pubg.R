#' Set API Key
#'
#' This function allows you to set your pubgtracker API key. It should be called prior to making any API calls.
#' @param apiKey Your public API key.
#' @keywords api, key
#' @export
#' @examples
#' set_api_key("00000000-0000-0000-0000-000000000000")
set_api_key <- function(apiKey) {
  api_key <<- apiKey
}

#' Fetch Player Statistics
#'
#' This function allows you to fetch player statistics for a single PUBG player. The player nickname is passed in as a parameter.
#' @param pubgNickname The PUBG player nickname that you are requesting statistics for.
#' @keywords stats, api, player
#' @export
#' @examples
#' fetch_pubg_player_stats("lazyjustin")
fetch_pubg_player_stats <- function(pubgNickname) {
  if( !exists("api_key") ) {
    print("Please specify a valid api key using the set_api_key function.")
    return(?set_api_key)
  }

  url <- "https://pubgtracker.com/api/profile/pc/"
  fullURL <- paste0(url, pubgNickname)
  response <- httr::GET(fullURL, httr::add_headers("TRN-Api-Key" = api_key))

  # Check response code, if not 200, return error to user
  response_code <- response$status_code
  if(response_code != 200) {
    print(paste0("HTTP Reponse: ", httr::http_status(response)$message))
    return()
  }

  # If we have a 200, try to parse the result (JSON)
  json <- jsonlite::fromJSON(httr::content(response, "text"))
  return(json)
}

#' Search for player by Steam ID (64-bit)
#'
#' This function allows you to search for PUBG players by 64-bit Steam ID. The object returned contains metadata about the player.
#' @param steam_id The 64-bit Steam ID that you want to search for.
#' @keywords api, player, search
#' @export
#' @examples
#' find_pubg_player_by_steam_id_64("10101010101010101")
find_pubg_player_by_steam_id_64 <- function(steam_id) {
  if( !exists("api_key") ) {
    print("Please specify a valid api key using the set_api_key function.")
    return(?set_api_key)
  }

  url <- "https://pubgtracker.com/api/search?steamId="
  fullURL <- paste0(url, steam_id)
  response <- httr::GET(fullURL, httr::add_headers("TRN-Api-Key" = api_key))

  # Check response code, if not 200, return error to user
  response_code <- response$status_code
  if(response_code != 200) {
    print(paste0("HTTP Reponse: ", httr::http_status(response)$message))
    return()
  }

  # If we have a 200, try to parse the result (JSON)
  json <- jsonlite::fromJSON(httr::content(response, "text"))
  return(json)
}

#' Fetch filtered stats for PUBG Player
#'
#' This function allows you to pull filtered statistics for a particular PUBG player. Use this function to optionally specify
#' a particular region, match-mode, and/or season to help filter your query results. If all three filters are applied, the
#' returning object will be a data-frame with only the results for a particular region, match, and season. See the examples below
#' for valid filter values.
#' @param pubgNickname The PUBG player nickname that you are requesting statistics for.
#' @param region The region of interest, example values include "na", "as", etc... For aggregated results across all regions, use "agg"
#' @param match The match type of interest: solo, duo, squad
#' @param season The season of interest: 2017-pre1, 2017-pre2, etc...
#' @keywords player, filter, stats
#' @export

fetch_filtered_pubg_player_stats <-  function(pubgNickname, region=NULL, match=NULL, season=NULL) {
  top <- fetch_pubg_player_stats(pubgNickname)
  top <- as.data.frame(top$Stats)
  if(!is.null(region)) {
    top <- subset(top, Region == region)
  }
  if(!is.null(match)) {
    top <- subset(top, Match == match)
  }
  if(!is.null(season)) {
    top <- subset(top, Season == season)
  }

  if(!is.null(region) & !is.null(match) & !is.null(season)) {
    stats <- as.data.frame(top$Stats)
    return(stats)
  }
  else {
    return(top)
  }
}
