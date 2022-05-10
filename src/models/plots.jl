plot_get_renderers(plot::Model; type, sides, filter=nothing) = PropVector(Model[m::Model for side in sides for m in getproperty(plot, side) if ismodelinstance(m::Model, type) && (filter === nothing || filter(m::Model))])
plot_get_renderers(; kw...) = (plot::Model) -> plot_get_renderers(plot; kw...)

function plot_get_renderer(plot::Model; plural, kw...)
    ms = plot_get_renderers(plot; kw...)
    if length(ms) == 0
        return Undefined()
    elseif length(ms) == 1
        return ms[1]
    else
        error("multiple $plural defined, consider using .$plural instead")
    end
end
plot_get_renderer(; kw...) = (plot::Model) -> plot_get_renderer(plot; kw...)

const Plot = ModelType("Plot";
    bases = [LayoutDOM],
    props = [
        :x_range => InstanceT(Range, default=()->DataRange1d()),
        :y_range => InstanceT(Range, default=()->DataRange1d()),
        :x_scale => InstanceT(Scale, default=()->LinearScale()),
        :y_scale => InstanceT(Scale, default=()->LinearScale()),
        :extra_x_ranges => DictT(StringT(), InstanceT(Range)),
        :extra_y_ranges => DictT(StringT(), InstanceT(Range)),
        :extra_x_scales => DictT(StringT(), InstanceT(Scale)),
        :extra_y_scales => DictT(StringT(), InstanceT(Scale)),
        :hidpi => BoolT(default=true),
        :title => NullableT(TitleT(), default=()->Title()),
        :title_location => NullableT(LocationT(), default="above"),
        :outline => SCALAR_LINE_PROPS,
        :outline_line_color => DefaultT("#e5e5e5"),
        :renderers => ListT(InstanceT(Renderer)),
        :toolbar => InstanceT(Toolbar, default=()->Toolbar()),
        :toolbar_location => NullableT(LocationT(), default="right"),
        :toolbar_sticky => BoolT(default=true),
        :left => ListT(InstanceT(Renderer)),
        :right => ListT(InstanceT(Renderer)),
        :above => ListT(InstanceT(Renderer)),
        :below => ListT(InstanceT(Renderer)),
        :center => ListT(InstanceT(Renderer)),
        :width => NullableT(IntT(), default=600),
        :height => NullableT(IntT(), default=600),
        :frame_width => NullableT(IntT()),
        :frame_height => NullableT(IntT()),
        # :inner_width => PropType(Any; default=nothing),
        # :inner_height => PropType(Any; default=nothing),
        # :outer_width => PropType(Any; default=nothing),
        # :outer_height => PropType(Any; default=nothing),
        :background => SCALAR_FILL_PROPS,
        :background_fill_color => DefaultT("#ffffff"),
        :border => SCALAR_FILL_PROPS,
        :border_fill_color => DefaultT("#ffffff"),
        :min_border_top => NullableT(IntT()),
        :min_border_bottom => NullableT(IntT()),
        :min_border_left => NullableT(IntT()),
        :min_border_right => NullableT(IntT()),
        :min_border => NullableT(IntT(), default=5),
        :lod_factor => IntT(default=10),
        :lod_threshold => NullableT(IntT(), default=2000),
        :lod_interval => IntT(default=300),
        :lod_timeout => IntT(default=500),
        :output_backend => OutputBackendT(default="canvas"),
        :match_aspect => BoolT(default=false),
        :aspect_scale => FloatT(default=1.0),
        :reset_policy => ResetPolicyT(default="standard"),

        # getters/setters
        :x_axis => GetSetT(plot_get_renderer(type=Axis, sides=[:below,:above], plural=:x_axes)),
        :y_axis => GetSetT(plot_get_renderer(type=Axis, sides=[:left,:right], plural=:y_axes)),
        :axis => GetSetT(plot_get_renderer(type=Axis, sides=[:below,:left,:above,:right], plural=:axes)),
        :x_axes => GetSetT(plot_get_renderers(type=Axis, sides=[:below,:above])),
        :y_axes => GetSetT(plot_get_renderers(type=Axis, sides=[:left,:right])),
        :axes => GetSetT(plot_get_renderers(type=Axis, sides=[:below,:left,:above,:right])),
        :x_grid => GetSetT(plot_get_renderer(type=Grid, sides=[:center], filter=m->m.dimension==0, plural=:x_grids)),
        :y_grid => GetSetT(plot_get_renderer(type=Grid, sides=[:center], filter=m->m.dimension==1, plural=:y_grids)),
        :grid => GetSetT(plot_get_renderer(type=Grid, sides=[:center], plural=:grids)),
        :x_grids => GetSetT(plot_get_renderers(type=Grid, sides=[:center], filter=m->m.dimension==0)),
        :y_grids => GetSetT(plot_get_renderers(type=Grid, sides=[:center], filter=m->m.dimension==1)),
        :grids => GetSetT(plot_get_renderers(type=Grid, sides=[:center])),
        :legend => GetSetT(plot_get_renderer(type=Legend, sides=[:below,:left,:above,:right,:center], plural=:legends)),
        :legends => GetSetT(plot_get_renderers(type=Legend, sides=[:below,:left,:above,:right,:center])),
        :tools => GetSetT((m)->(m.toolbar.tools), (m,v)->(m.toolbar.tools=v)),
        :ranges => GetSetT(m->PropVector([m.x_range::Model, m.y_range::Model])),
        :scales => GetSetT(m->PropVector([m.x_scale::Model, m.y_scale::Model])),
    ],
)

const Figure = ModelType("Plot", "Figure";
    bases = [Plot],
)
