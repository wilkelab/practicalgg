library(tidyverse)
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
    ggforce::geom_arc_bar(
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
    cowplot::theme_map()

  vdiffr::expect_doppelganger("Bundestag pie", p)
})

test_that("corruption", {
  corrupt <- practicalgg::corruption %>%
    filter(year == 2015) %>%
    na.omit()

  region_cols <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#999999")

  corrupt <- corrupt %>%
    mutate(region = case_when(
      region == "Middle East and North Africa" ~ "Middle East\nand North Africa",
      region == "Europe and Central Asia" ~ "Europe and\nCentral Asia",
      region == "Sub Saharan Africa" ~ "Sub-Saharan\nAfrica",
      TRUE ~ region)
    )

  country_highlight <- c("Germany", "Norway", "United States", "Greece", "Singapore", "Rwanda", "Russia", "Venezuela", "Sudan", "Iraq", "Ghana", "Niger", "Chad", "Kuwait", "Qatar", "Myanmar", "Nepal", "Chile", "Argentina", "Japan", "China")

  corrupt <- corrupt %>%
    mutate(
      label = ifelse(country %in% country_highlight, country, "")
    )

  p <- ggplot(corrupt, aes(cpi, hdi)) +
    geom_smooth(
      aes(color = "y ~ log(x)", fill = "y ~ log(x)"),
      method = 'lm', formula = y~log(x), se = FALSE, fullrange = TRUE
    ) +
    geom_point(
      aes(color = region, fill = region),
      size = 2.5, alpha = 0.5, shape = 21
    ) +
    ggrepel::geom_text_repel(
      aes(label = label),
      color = "black",
      size = 9/.pt, # font size 9 pt
      point.padding = 0.1,
      box.padding = .6,
      min.segment.length = 0,
      max.overlaps = 1000,
      seed = 7654
    ) +
    scale_color_manual(
      name = NULL,
      values = colorspace::darken(region_cols, 0.3)
    ) +
    scale_fill_manual(
      name = NULL,
      values = region_cols
    ) +
    scale_x_continuous(
      name = "Corruption Perceptions Index, 2015 (100 = least corrupt)",
      limits = c(10, 95),
      breaks = c(20, 40, 60, 80, 100),
      expand = c(0, 0)
    ) +
    scale_y_continuous(
      name = "Human Development Index, 2015\n(1.0 = most developed)",
      limits = c(0.3, 1.05),
      breaks = c(0.2, 0.4, 0.6, 0.8, 1.0),
      expand = c(0, 0)
    ) +
    guides(
      color = guide_legend(
        nrow = 1,
        override.aes = list(
          linetype = c(rep(0, 5), 1),
          shape = c(rep(21, 5), NA)
        )
      )
    ) +
    cowplot::theme_minimal_hgrid(12, rel_small = 1) +
    theme(
      legend.position = "top",
      legend.justification = "right",
      legend.text = element_text(size = 9),
      legend.box.spacing = unit(0, "pt")
    )

  vdiffr::expect_doppelganger("corruption", p)
})

test_that("goode", {
  world_sf <- st_as_sf(rworldmap::getMap(resolution = "low"))

  crs_goode <- "+proj=igh"
  lats <- c(
    90:-90, # right side down
    -90:0, 0:-90, # third cut bottom
    -90:0, 0:-90, # second cut bottom
    -90:0, 0:-90, # first cut bottom
    -90:90, # left side up
    90:0, 0:90, # cut top
    90 # close
  )
  longs <- c(
    rep(180, 181), # right side down
    rep(c(80.01, 79.99), each = 91), # third cut bottom
    rep(c(-19.99, -20.01), each = 91), # second cut bottom
    rep(c(-99.99, -100.01), each = 91), # first cut bottom
    rep(-180, 181), # left side up
    rep(c(-40.01, -39.99), each = 91), # cut top
    180 # close
  )

  goode_outline <-
    list(cbind(longs, lats)) %>%
    st_polygon() %>%
    st_sfc(
      crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    )
  goode_outline <- st_transform(goode_outline, crs = crs_goode)

  # get the bounding box in transformed coordinates and expand by 10%
  xlim <- st_bbox(goode_outline)[c("xmin", "xmax")]*1.1
  ylim <- st_bbox(goode_outline)[c("ymin", "ymax")]*1.1

  # turn into enclosing rectangle
  goode_encl_rect <-
    list(
      cbind(
        c(xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]),
        c(ylim[1], ylim[1], ylim[2], ylim[2], ylim[1])
      )
    ) %>%
    st_polygon() %>%
    st_sfc(crs = crs_goode)

  # calculate the area outside the earth outline as the difference
  # between the enclosing rectangle and the earth outline
  goode_without <- st_difference(goode_encl_rect, goode_outline)

  p <- ggplot(world_sf) +
    geom_sf(fill = "#E69F00B0", color = "black", size = 0.5/.pt) +
    geom_sf(data = goode_without, fill = "white", color = "NA") +
    geom_sf(data = goode_outline, fill = NA, color = "gray30", size = 0.5/.pt) +
    coord_sf(crs = crs_goode, xlim = 0.95*xlim, ylim = 0.95*ylim, expand = FALSE) +
    cowplot::theme_minimal_grid() +
    theme(
      panel.background = element_rect(fill = "#56B4E950", color = "white", size = 1),
      panel.grid.major = element_line(color = "gray30", size = 0.25)
    )

  vdiffr::expect_doppelganger("goode", p)
})

test_that("health status", {
  data_health <- practicalgg::happy %>%
    select(age, health) %>%
    na.omit() %>%
    mutate(health = fct_rev(health)) # revert factor order

  p <- ggplot(data_health, aes(x = age, y = stat(count))) +
    geom_density(
      data = select(data_health, -health),
      aes(fill = "all people surveyed   "),
      color = NA
    ) +
    geom_density(aes(fill = "highlighted group"), color = NA) +
    scale_x_continuous(
      name = "age (years)",
      limits = c(15, 98),
      expand = c(0, 0)
    ) +
    scale_y_continuous(
      name = "count",
      expand = c(0, 0)
    ) +
    scale_fill_manual(
      values = c("#b3b3b3a0", "#2b8cbed0"),
      name = NULL,
      guide = guide_legend(direction = "horizontal")
    ) +
    facet_wrap(~health, nrow = 1) +
    coord_cartesian(clip = "off") +
    cowplot::theme_minimal_hgrid(12) +
    theme(
      axis.line = element_blank(),
      strip.text = element_text(size = 12, margin = margin(0, 0, 6, 0, "pt")),
      legend.position = "bottom",
      legend.justification = "right",
      legend.margin = margin(6, 0, 1.5, 0, "pt"),
      legend.spacing.x = grid::unit(3, "pt"),
      legend.spacing.y = grid::unit(0, "pt"),
      legend.box.spacing = grid::unit(0, "pt")
    )

  vdiffr::expect_doppelganger("health status", p)
})

test_that("Texas income", {
  texas_income <- practicalgg::texas_income
  texas_crs <- "+proj=aea +lat_1=27.5 +lat_2=35 +lat_0=18 +lon_0=-100 +x_0=1500000 +y_0=6000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
  texas_transf <- st_transform(texas_income, crs = texas_crs)
  texas_xlim <- c(538250, 2125629)

  p <- ggplot(texas_transf, aes(fill = estimate)) +
    geom_sf(color = "white") +
    coord_sf(xlim = texas_xlim) +
    colorspace::scale_fill_continuous_sequential(
      palette = "Blues", rev = TRUE,
      na.value = "grey60",
      name = "annual median income (USD)",
      limits = c(18000, 90000),
      breaks = 20000*c(1:4),
      labels = c("$20,000", "$40,000", "$60,000", "$80,000"),
      guide = guide_colorbar(
        direction = "horizontal",
        label.position = "bottom",
        title.position = "top",
        barwidth = grid::unit(3.0, "in"),
        barheight = grid::unit(0.2, "in")
      )
    ) +
    cowplot::theme_map(12) +
    theme(
      legend.title.align = 0.5,
      legend.text.align = 0.5,
      legend.justification = c(0, 0),
      legend.position = c(0.02, 0.1)
    )

  vdiffr::expect_doppelganger("Texas income", p)
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
    cowplot::theme_map()

  vdiffr::expect_doppelganger("Winkel tripel", p)
})
