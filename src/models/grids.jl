const Grid = ModelType("Grid";
    bases = [GuideRenderer],
    props = [
        :dimension => IntT() |> DefaultT(0),
        :axis => InstanceT(Axis) |> NullableT,
        :grid => SCALAR_LINE_PROPS,
        :grid_line_color => DefaultT("#e5e5e5"),
        :minor_grid => SCALAR_LINE_PROPS,
        :minor_grid_line_color => DefaultT(nothing),
        :band => SCALAR_FILL_PROPS,
        :band_fill_alpha => DefaultT(0),
        :band_fill_color => DefaultT(nothing),
        :band => SCALAR_HATCH_PROPS,
        :level => DefaultT("underlay"),
    ],
)
