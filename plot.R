library(ggplot2)
library(patchwork)

weather <- read.csv("weather_data.csv", check.names = FALSE)
weather$time <- as.POSIXct(
  weather$time,
  format = "%Y-%m-%dT%H:%M",
  tz = "America/Los_Angeles"
)

weather_long <- data.frame(
  time = rep(weather$time, 3),
  measure = rep(
    c("Temperature (°C)", "Humidity (%)", "Wind speed (km/h)"),
    each = nrow(weather)
  ),
  value = c(
    weather[["temperature_2m (°C)"]],
    weather[["relative_humidity_2m (%)"]],
    weather[["wind_speed_10m (km/h)"]]
  )
)

bear_image <- magick::image_read("grizzly-bear.jpg") |>
  magick::image_crop("960x480+0+0")

title_plot <- ggplot() +
  annotate(
    "text", x = 0, y = 0.7, label = "Monterey weather",
    hjust = 0, color = "#006633", fontface = "bold", size = 7
  ) +
  annotate(
    "text", x = 0, y = 0.3,
    label = "Hourly conditions • February 12, 2006–February 12, 2016 • Monterey, California",
    hjust = 0, color = "#555555", size = 3.5
  ) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
  theme_void()

bear_plot <- ggplot() +
  annotation_raster(
    as.raster(bear_image),
    xmin = 0, xmax = 1, ymin = 0, ymax = 1
  ) +
  coord_fixed(ratio = 0.5, xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
  theme_void()

weather_plot <- ggplot(
  weather_long,
  aes(x = time, y = value, color = measure, fill = measure)
) +
  geom_area(alpha = 0.15, position = "identity") +
  geom_line(linewidth = 1) +
  facet_grid(rows = vars(measure), scales = "free_y", switch = "y") +
  scale_color_manual(
    values = c(
      "Temperature (°C)" = "#C8102E",
      "Humidity (%)" = "#006633",
      "Wind speed (km/h)" = "#8B4513"
    )
  ) +
  scale_fill_manual(
    values = c(
      "Temperature (°C)" = "#C8102E",
      "Humidity (%)" = "#006633",
      "Wind speed (km/h)" = "#8B4513"
    )
  ) +
  scale_x_datetime(
    date_labels = "%Y",
    date_breaks = "2 years",
    expand = expansion(mult = c(0.01, 0.02))
  ) +
  labs(
    x = NULL,
    y = NULL,
    caption = paste(
      "Weather: Open-Meteo | Bear photo: Gregory \"Slobirdr\" Smith,",
      "\"Grizzly Bear (Ursus arctos ssp.)\", CC BY-SA 2.0, Wikimedia Commons (cropped)"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#e5e5e5"),
    panel.spacing.y = unit(0.8, "lines"),
    strip.background = element_blank(),
    strip.placement = "outside",
    strip.text.y.left = element_text(color = "#333333", angle = 0, hjust = 1),
    axis.text = element_text(color = "#333333"),
    axis.title = element_text(color = "#333333"),
    plot.caption = element_text(color = "#666666"),
    legend.position = "none"
  )

weather_plot <- (title_plot | bear_plot) / weather_plot +
  plot_layout(heights = c(0.17, 1), widths = c(4, 1.4))

ggsave(
  "monterey-weather.png",
  plot = weather_plot,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)
