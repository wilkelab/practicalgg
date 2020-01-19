library(tidyverse)
library(cowplot)
library(ggforce)
library(sf)

context("visual")

test_that("Bundestag pie", {
  bundestag <- practicalgg::bundestag %>%
    select(party, seats, colors)

  bund_pie <- bundestag %>%
    arrange(seats) %>%
    mutate(
      end_angle = 2*pi*cumsum(seats)/sum(seats),   # ending angle for each pie slice
      start_angle = lag(end_angle, default = 0),   # starting angle for each pie slice
      mid_angle = 0.5*(start_angle + end_angle),   # middle of each pie slice, for the text label
      # horizontal and vertical justifications depend on whether we're to the left/right
      # or top/bottom of the pie
      hjust = ifelse(mid_angle > pi, 1, 0),
      vjust = ifelse(mid_angle < pi/2 | mid_angle > 3*pi/2, 0, 1)
    )

  bund_pie

  # radius of the pie and radius for outside and inside labels
  rpie <- 1
  rlabel_out <- 1.05 * rpie
  rlabel_in <- 0.6 * rpie

  p <- ggplot(bund_pie) +
    geom_arc_bar(
      aes(
        x0 = 0, y0 = 0, r0 = 0, r = rpie,
        start = start_angle, end = end_angle, fill = colors
      ),
      color = "white"
    ) +
    geom_text(
      aes(
        x = rlabel_in * sin(mid_angle),
        y = rlabel_in * cos(mid_angle),
        label = seats
      ),
      size = 14/.pt,
      color = c("black", "white", "white")
    ) +
    geom_text(
      aes(
        x = rlabel_out * sin(mid_angle),
        y = rlabel_out * cos(mid_angle),
        label = party,
        hjust = hjust, vjust = vjust
      ),
      size = 14/.pt
    ) +
    scale_x_continuous(
      name = NULL,
      limits = c(-1.5, 1.4),
      expand = c(0, 0)
    ) +
    scale_y_continuous(
      name = NULL,
      limits = c(-1.05, 1.15),
      expand = c(0, 0)
    ) +
    scale_fill_identity() +
    coord_fixed() +
    theme_map()

  vdiffr::expect_doppelganger("Bundestag pie", p)
})


test_that("Winkel tripel", {
  world_sf <- st_as_sf(rworldmap::getMap(resolution = "low"))

  crs_wintri <- "+proj=wintri +datum=WGS84 +no_defs +over"
  world_wintri <- lwgeom::st_transform_proj(world_sf, crs = crs_wintri)

  grat_wintri <-
    st_graticule(lat = c(-89.9, seq(-80, 80, 20), 89.9)) %>%
    lwgeom::st_transform_proj(crs = crs_wintri)

  # vectors of latitudes and longitudes that go once around the
  # globe in 1-degree steps
  lats <- c(90:-90, -90:90, 90)
  longs <- c(rep(c(180, -180), each = 181), 180)

  # turn into correctly projected sf collection
  wintri_outline <-
    list(cbind(longs, lats)) %>%
    st_polygon() %>%
    st_sfc( # create sf geometry list column
      crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    ) %>%
    st_sf() %>%
    lwgeom::st_transform_proj(crs = crs_wintri) # transform to Winkel tripel

  p <- ggplot() +
    geom_sf(data = wintri_outline, fill = "#56B4E950", color = NA) +
    geom_sf(data = grat_wintri, color = "gray30", size = 0.25/.pt) +
    geom_sf(
      data = world_wintri,
      fill = "#E69F00B0", color = "black", size = 0.5/.pt
    ) +
    geom_sf(data = wintri_outline, fill = NA, color = "grey30", size = 0.5/.pt) +
    coord_sf(datum = NULL) +
    theme_map()

  vdiffr::expect_doppelganger("Winkel tripel", p)
})
