#' Plot a soil profile
#'
#' @param profile A `soil_profile` object.
#'
#' @return A `ggplot2` object.
#' @export
#' @examples
#' \donttest{
#' h1 <- new_soil_horizon(0, 18, label = "Ap", color = "#5C4033")
#' h2 <- new_soil_horizon(18, 52, label = "Bt1", color = "#8A5A44")
#' h3 <- new_soil_horizon(52, 95, label = "Bt2", color = "#A66A4C")
#' profile <- new_soil_profile("pedon-001", list(h1, h2, h3),
#'   classification = list(system = "Soil Taxonomy", taxon = "Typic Hapludalf"))
#' plot_soil_profile(profile)
#' }
plot_soil_profile <- function(profile) {
    validate_soil_profile(profile)
    .data <- rlang::.data

    horizon_count <- length(profile$horizons)
    fallback_colors <- grDevices::hcl.colors(horizon_count, palette = "Terrain 2", rev = TRUE)

    plot_data <- data.frame(
        label = vapply(
            seq_along(profile$horizons),
            function(index) profile$horizons[[index]]$label %||% paste0("H", index),
            character(1)
        ),
        top = vapply(profile$horizons, function(horizon) horizon$top, numeric(1)),
        bottom = vapply(profile$horizons, function(horizon) horizon$bottom, numeric(1)),
        fill = vapply(
            seq_along(profile$horizons),
            function(index) {
                candidate <- profile$horizons[[index]]$color
                if (is_valid_color(candidate)) {
                    candidate
                } else {
                    fallback_colors[[index]]
                }
            },
            character(1)
        )
    )

    plot_data$midpoint <- (plot_data$top + plot_data$bottom) / 2

    ggplot2::ggplot(plot_data) +
        ggplot2::geom_rect(
            ggplot2::aes(
                xmin = 0,
                xmax = 1,
                ymin = .data$top,
                ymax = .data$bottom,
                fill = .data$fill
            ),
            color = "#2F241D",
            linewidth = 0.3
        ) +
        ggplot2::geom_text(
            ggplot2::aes(x = 0.5, y = .data$midpoint, label = .data$label),
            family = "sans",
            size = 3.5
        ) +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_y_reverse(expand = c(0, 0)) +
        ggplot2::coord_cartesian(xlim = c(0, 1), clip = "off") +
        ggplot2::labs(
            title = profile$site_id,
            subtitle = profile$classification$taxon %||% profile$classification$system,
            x = NULL,
            y = "Depth (cm)"
        ) +
        ggplot2::theme_minimal(base_size = 12) +
        ggplot2::theme(
            axis.text.x = ggplot2::element_blank(),
            axis.ticks.x = ggplot2::element_blank(),
            panel.grid.major.x = ggplot2::element_blank(),
            panel.grid.minor = ggplot2::element_blank(),
            legend.position = "none"
        )
}

#' Plot a soil profile with encoded coarse fragment properties
#'
#' @param profile A `soil_profile` object.
#' @param seed Random seed for deterministic coarse fragment placement.
#'
#' @return A `ggplot2` object.
#' @export
#' @examples
#' \donttest{
#' h1 <- new_soil_horizon(0, 18, label = "Ap", color = "#5C4033",
#'   coarse_abundance = "few", coarse_shape = "subangular",
#'   coarse_grade = "weak", coarse_type = "gravel")
#' h2 <- new_soil_horizon(18, 52, label = "Bt1", color = "#8A5A44",
#'   coarse_abundance = "common", coarse_shape = "rounded",
#'   coarse_grade = "moderate", coarse_type = "cobble")
#' profile <- new_soil_profile("pedon-001", list(h1, h2))
#' plot_soil_profile_fragments(profile)
#' }
plot_soil_profile_fragments <- function(profile, seed = 1) {
    validate_soil_profile(profile)
    .data <- rlang::.data

    horizon_data <- build_horizon_plot_data(profile)
    boundary_data <- build_boundary_paths(horizon_data, seed = seed)
    fragment_data <- build_fragment_layout(horizon_data, seed = seed)

    fragment_shape_values <- c(
        gravel = 16,
        cobble = 15,
        stone = 17,
        boulder = 18,
        channer = 3,
        flagstone = 0
    )

    plot <- ggplot2::ggplot() +
        ggplot2::geom_rect(
            data = horizon_data,
            ggplot2::aes(
                xmin = 0,
                xmax = 1,
                ymin = .data$top,
                ymax = .data$bottom,
                fill = .data$fill
            ),
            color = "#2F241D",
            linewidth = 0.3
        )

    if (nrow(boundary_data) > 0) {
        plot <- plot +
            ggplot2::geom_path(
                data = boundary_data,
                ggplot2::aes(x = .data$x, y = .data$y, group = .data$boundary_id),
                color = "#1B1B1B",
                linewidth = 0.5
            )
    }

    plot <- plot +
        ggplot2::geom_text(
            data = horizon_data,
            ggplot2::aes(x = 0.5, y = .data$midpoint, label = .data$label),
            family = "sans",
            size = 3.5
        )

    if (nrow(fragment_data) > 0) {
        plot <- plot +
            ggplot2::geom_point(
                data = fragment_data,
                ggplot2::aes(
                    x = .data$x,
                    y = .data$y,
                    shape = .data$coarse_type,
                    size = .data$marker_size,
                    alpha = .data$marker_alpha,
                    color = .data$marker_color
                ),
                stroke = 0.25
            ) +
            ggplot2::scale_shape_manual(values = fragment_shape_values, drop = FALSE) +
            ggplot2::scale_size_identity() +
            ggplot2::scale_alpha_identity() +
            ggplot2::scale_color_identity()
    }

    plot +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_y_reverse(expand = c(0, 0)) +
        ggplot2::coord_cartesian(xlim = c(0, 1), clip = "off") +
        ggplot2::labs(
            title = profile$site_id,
            subtitle = profile$classification$taxon %||% profile$classification$system,
            x = NULL,
            y = "Depth (cm)",
            shape = "Coarse type"
        ) +
        ggplot2::theme_minimal(base_size = 12) +
        ggplot2::theme(
            axis.text.x = ggplot2::element_blank(),
            axis.ticks.x = ggplot2::element_blank(),
            panel.grid.major.x = ggplot2::element_blank(),
            panel.grid.minor = ggplot2::element_blank(),
            legend.position = "right"
        )
}

#' Plot soil profile with advanced graphical engines
#'
#' Creates a detailed soil profile visualization using custom graphical engines
#' for coarse fragments (polygons) and horizon boundaries (irregular lines).
#' This function provides a more sophisticated rendering compared to the basic
#' point-based visualization.
#'
#' @param profile A `soil_profile` object.
#' @param show_fragments Logical: whether to render coarse fragments as polygons.
#' @param show_boundaries Logical: whether to render boundary transitions.
#' @param show_transition_zones Logical: whether to show gradual/diffuse transition zones.
#' @param seed Random seed for deterministic rendering.
#'
#' @return A `ggplot2` object.
#' @export
plot_soil_profile_advanced <- function(
    profile,
    show_fragments = TRUE,
    show_boundaries = TRUE,
    show_transition_zones = TRUE,
    seed = 1
) {
    validate_soil_profile(profile)
    .data <- rlang::.data

    horizon_data <- build_horizon_plot_data(profile)

    # Starting plot with horizon backgrounds
    plot <- ggplot2::ggplot() +
        ggplot2::geom_rect(
            data = horizon_data,
            ggplot2::aes(
                xmin = 0,
                xmax = 1,
                ymin = .data$top,
                ymax = .data$bottom,
                fill = .data$fill
            ),
            color = "#2F241D",
            linewidth = 0.3
        ) +
        ggplot2::scale_fill_identity()

    # Add transition zones if requested
    if (show_transition_zones) {
        zone_data <- build_boundary_transition_zones(horizon_data, seed = seed)
        zone_layers <- layer_boundary_transition_zones(zone_data)
        plot <- plot + zone_layers
    }

    # Add boundary lines if requested
    if (show_boundaries) {
        boundary_data <- build_boundary_paths(horizon_data, seed = seed)
        boundary_layers <- layer_horizon_boundaries(boundary_data)
        plot <- plot + boundary_layers
    }

    # Add coarse fragment polygons if requested
    if (show_fragments) {
        fragment_data <- build_fragment_polygons(profile, seed = seed)
        fragment_layers <- layer_coarse_fragments(fragment_data)
        plot <- plot + fragment_layers
    }

    # Add horizon labels
    plot <- plot +
        ggplot2::geom_text(
            data = horizon_data,
            ggplot2::aes(x = 0.5, y = .data$midpoint, label = .data$label),
            family = "sans",
            size = 3.5,
            fontface = "bold"
        )

    # Complete plot with axes and theme
    plot +
        ggplot2::scale_y_reverse(expand = c(0, 0)) +
        ggplot2::coord_cartesian(xlim = c(0, 1), clip = "off") +
        ggplot2::labs(
            title = profile$site_id,
            subtitle = profile$classification$taxon %||% profile$classification$system,
            x = NULL,
            y = "Depth (cm)"
        ) +
        theme_soil_profile(base_size = 12, show_grid = FALSE)
}

#' Plot a field description table with encoded coarse fragment properties
#'
#' @param data A data frame with `Depth` and `description` columns.
#' @param site_id Profile identifier. Defaults to `"soil-profile"`.
#' @param profile_bottom Optional terminal depth in centimeters. Required when
#'   `Depth` contains top depths rather than depth ranges.
#' @param classification A named list describing the classification system and taxon.
#' @param metadata A named list with arbitrary profile metadata.
#' @param seed Random seed for deterministic coarse fragment placement.
#'
#' @return A `ggplot2` object.
#' @export
#' @examples
#' \donttest{
#' field_notes <- data.frame(
#'   Depth = c("0-18 cm", "18-52 cm", "52-95 cm"),
#'   description = c(
#'     "Ap dark brown silt loam moist clear smooth few subangular weak fragments",
#'     "Bt1 reddish brown clay loam gradual wavy common rounded moderate fragments",
#'     "Bt2 brown clay diffuse irregular many subrounded strong fragments"
#'   )
#' )
#' plot_soil_description_fragments(field_notes, site_id = "pedon-001")
#' }
plot_soil_description_fragments <- function(
    data,
    site_id = "soil-profile",
    profile_bottom = NULL,
    classification = list(system = "Field description", taxon = NULL),
    metadata = list(),
    seed = 1
) {
    profile <- soil_profile_from_table(
        data = data,
        site_id = site_id,
        profile_bottom = profile_bottom,
        classification = classification,
        metadata = metadata
    )

    plot_soil_profile_fragments(profile, seed = seed)
}

#' Plot a soil profile from a two-column field description table
#'
#' @param data A data frame with `Depth` and `description` columns.
#' @param site_id Profile identifier. Defaults to `"soil-profile"`.
#' @param profile_bottom Optional terminal depth in centimeters. Required when
#'   `Depth` contains top depths rather than depth ranges.
#' @param classification A named list describing the classification system and taxon.
#' @param metadata A named list with arbitrary profile metadata.
#'
#' @return A `ggplot2` object.
#' @export
#' @examples
#' \donttest{
#' field_notes <- data.frame(
#'   Depth = c("0-18 cm", "18-52 cm", "52-95 cm"),
#'   description = c(
#'     "Ap dark brown silt loam moist clear smooth",
#'     "Bt1 reddish brown clay loam slightly moist gradual wavy",
#'     "Bt2 brown clay dry diffuse irregular"
#'   )
#' )
#' plot_soil_description(field_notes, site_id = "pedon-001")
#' }
plot_soil_description <- function(
    data,
    site_id = "soil-profile",
    profile_bottom = NULL,
    classification = list(system = "Field description", taxon = NULL),
    metadata = list()
) {
    profile <- soil_profile_from_table(
        data = data,
        site_id = site_id,
        profile_bottom = profile_bottom,
        classification = classification,
        metadata = metadata
    )

    plot_soil_profile(profile)
}



#' @keywords internal
build_fragment_layout <- function(horizon_data, seed = 1) {
    rows <- lapply(seq_len(nrow(horizon_data)), function(index) {
        abundance <- horizon_data$coarse_abundance[[index]]
        percent <- horizon_data$coarse_percent[[index]]
        count <- coarse_fragment_count(abundance, percent)

        if (count <= 0) {
            return(NULL)
        }

        set.seed(seed + 100 * index)

        data.frame(
            x = stats::runif(count, 0.07, 0.93),
            y = stats::runif(count, horizon_data$top[[index]] + 0.8, horizon_data$bottom[[index]] - 0.8),
            coarse_type = normalize_fragment_type(horizon_data$coarse_type[[index]]),
            marker_size = coarse_size_to_marker(horizon_data$coarse_size[[index]]),
            marker_alpha = coarse_grade_to_alpha(horizon_data$coarse_grade[[index]]),
            marker_color = normalized_fragment_color(horizon_data$coarse_color[[index]]),
            stringsAsFactors = FALSE
        )
    })

    rows <- Filter(Negate(is.null), rows)

    if (length(rows) == 0) {
        return(data.frame())
    }

    do.call(rbind, rows)
}
