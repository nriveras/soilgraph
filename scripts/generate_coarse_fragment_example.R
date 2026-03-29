library(ggplot2)

set.seed(42)

horizons <- data.frame(
    horizon = c("Ap", "Bt1", "Bt2", "BC"),
    top = c(0, 18, 45, 80),
    bottom = c(18, 45, 80, 120),
    fill = c("#5C4033", "#7B3F2A", "#8B5A2B", "#9A7A4A"),
    coarse_percent = c(5, 15, 30, 45),
    coarse_type = c("gravel", "cobble", "stone", "gravel"),
    boundary_shape = c("smooth", "wavy", "irregular", NA),
    stringsAsFactors = FALSE
)

if (!dir.exists("outputs")) {
    dir.create("outputs", recursive = TRUE)
}

write.csv(horizons, "outputs/example-coarse-fragments-table.csv", row.names = FALSE)

shape_map <- c(gravel = 16, cobble = 15, stone = 17)

points_list <- lapply(seq_len(nrow(horizons)), function(i) {
    row <- horizons[i, ]

    n_points <- max(5, round(row$coarse_percent * 1.2))

    data.frame(
        x = runif(n_points, 0.08, 0.92),
        y = runif(n_points, row$top + 0.8, row$bottom - 0.8),
        coarse_type = row$coarse_type,
        stringsAsFactors = FALSE
    )
})

coarse_points <- do.call(rbind, points_list)
coarse_points$shape <- unname(shape_map[coarse_points$coarse_type])

boundaries <- horizons[seq_len(nrow(horizons) - 1), c("bottom", "boundary_shape")]
names(boundaries)[1] <- "depth"

line_data <- do.call(rbind, lapply(seq_len(nrow(boundaries)), function(i) {
    boundary <- boundaries[i, ]

    x_vals <- seq(0, 1, length.out = 150)
    y_vals <- rep(boundary$depth, length(x_vals))

    if (boundary$boundary_shape == "wavy") {
        y_vals <- y_vals + 0.7 * sin(seq(0, 6 * pi, length.out = length(x_vals)))
    }

    if (boundary$boundary_shape == "irregular") {
        noise <- cumsum(rnorm(length(x_vals), mean = 0, sd = 0.06))
        noise <- noise - mean(noise)
        y_vals <- y_vals + noise
    }

    data.frame(
        x = x_vals,
        y = y_vals,
        boundary_shape = boundary$boundary_shape,
        stringsAsFactors = FALSE
    )
}))

plot <- ggplot() +
    geom_rect(
        data = horizons,
        aes(xmin = 0, xmax = 1, ymin = top, ymax = bottom, fill = fill),
        color = "#2F241D",
        linewidth = 0.35
    ) +
    geom_path(
        data = line_data,
        aes(x = x, y = y, group = interaction(y, boundary_shape)),
        color = "#111111",
        linewidth = 0.55
    ) +
    geom_text(
        data = horizons,
        aes(x = 0.5, y = (top + bottom) / 2, label = paste0(horizon, " (", coarse_percent, "% ", coarse_type, ")")),
        size = 3.6,
        family = "sans"
    ) +
    geom_point(
        data = coarse_points,
        aes(x = x, y = y, shape = coarse_type),
        color = "#1B1B1B",
        fill = "#1B1B1B",
        alpha = 0.8,
        size = 1.7,
        stroke = 0.2
    ) +
    scale_shape_manual(values = shape_map, name = "Coarse fragment type") +
    scale_fill_identity() +
    scale_y_reverse(expand = c(0, 0)) +
    coord_cartesian(xlim = c(0, 1), clip = "off") +
    labs(
        title = "Example Soil Profile with Coarse Fragments and Boundary Shapes",
        subtitle = "Boundary shapes: smooth, wavy, irregular",
        x = NULL,
        y = "Depth (cm)"
    ) +
    theme_minimal(base_size = 12) +
    theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "right"
    )

ggsave(
    filename = "outputs/example-coarse-fragments-plot.png",
    plot = plot,
    width = 7,
    height = 8,
    units = "in",
    dpi = 160
)
