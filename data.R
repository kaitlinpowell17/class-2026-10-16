url <- paste0(
  "https://archive-api.open-meteo.com/v1/archive?",
  "latitude=36.6002&longitude=-121.8947",
  "&start_date=2006-02-12&end_date=2016-02-12",
  "&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m",
  "&timezone=America%2FLos_Angeles&format=csv"
)

# The CSV response starts with two metadata rows and a blank line.
weather <- read.csv(url, skip = 3, check.names = FALSE)

write.csv(weather, "weather_data.csv", row.names = FALSE)
